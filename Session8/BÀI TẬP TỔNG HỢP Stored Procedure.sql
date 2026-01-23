-- Bảng khách hàng (2 triệu records)

CREATE TABLE KhachHang (

    id SERIAL PRIMARY KEY,

    ma_kh VARCHAR(20) UNIQUE NOT NULL,

    ho_ten VARCHAR(100) NOT NULL,

    so_du DECIMAL(15,2) DEFAULT 0.00,

    trang_thai VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT NOW()

);

-- Bảng tài khoản (3 triệu records - mỗi KH có thể nhiều TK)

CREATE TABLE TaiKhoan (

    id SERIAL PRIMARY KEY,

    ma_tk VARCHAR(20) UNIQUE NOT NULL,

    khach_hang_id INTEGER REFERENCES KhachHang(id),

    so_du DECIMAL(15,2) DEFAULT 0.00,

    loai_tk VARCHAR(50) DEFAULT 'THUONG',

    trang_thai VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT NOW()

);

-- Bảng giao dịch (20 triệu records)

CREATE TABLE GiaoDich (

    id SERIAL PRIMARY KEY,

    ma_gd VARCHAR(30) UNIQUE NOT NULL,

    tai_khoan_id INTEGER REFERENCES TaiKhoan(id),

    loai_gd VARCHAR(20) NOT NULL, -- 'CHUYEN_TIEN', 'RUT_TIEN', 'GUI_TIEN'

    so_tien DECIMAL(15,2) NOT NULL,

    tai_khoan_doi_tac INTEGER, -- Dùng cho chuyển tiền

    noi_dung TEXT,

    trang_thai VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT NOW()

);

-- Bảng lịch sử số dư

CREATE TABLE LichSuSoDu (

    id SERIAL PRIMARY KEY,

    tai_khoan_id INTEGER REFERENCES TaiKhoan(id),

    so_du_truoc DECIMAL(15,2),

    so_du_sau DECIMAL(15,2),

    thoi_gian TIMESTAMP DEFAULT NOW()

);

---- Chuyển tiền giữa 2 tài khoản
CREATE OR REPLACE PROCEDURE chuyen_tien(
    p_ma_tk_nguoi_gui  VARCHAR,
    p_ma_tk_nguoi_nhan VARCHAR,
    p_so_tien          DECIMAL,
    p_noi_dung         TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk_gui_id    INT;
    v_tk_nhan_id   INT;
    v_so_du_gui    DECIMAL;
    v_so_du_nhan   DECIMAL;
    v_ma_gd        VARCHAR;
BEGIN
    -- 1. Kiểm tra tài khoản người gửi tồn tại & ACTIVE
    SELECT id, so_du
    INTO v_tk_gui_id, v_so_du_gui
    FROM TaiKhoan
    WHERE ma_tk = p_ma_tk_nguoi_gui
      AND trang_thai = 'ACTIVE'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản người gửi không tồn tại hoặc không ACTIVE';
    END IF;

    -- 2. Kiểm tra tài khoản người nhận tồn tại & ACTIVE
    SELECT id, so_du
    INTO v_tk_nhan_id, v_so_du_nhan
    FROM TaiKhoan
    WHERE ma_tk = p_ma_tk_nguoi_nhan
      AND trang_thai = 'ACTIVE'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản người nhận không tồn tại hoặc không ACTIVE';
    END IF;

    -- 3. Kiểm tra số dư
    IF v_so_du_gui < p_so_tien THEN
        RAISE EXCEPTION 'Số dư không đủ';
    END IF;

    -- 4. Trừ tiền người gửi
    UPDATE TaiKhoan
    SET so_du = so_du - p_so_tien
    WHERE id = v_tk_gui_id;

    -- 5. Cộng tiền người nhận
    UPDATE TaiKhoan
    SET so_du = so_du + p_so_tien
    WHERE id = v_tk_nhan_id;

    -- 6. Ghi lịch sử số dư
    INSERT INTO LichSuSoDu(tai_khoan_id, so_du_truoc, so_du_sau)
    VALUES
        (v_tk_gui_id,  v_so_du_gui,  v_so_du_gui  - p_so_tien),
        (v_tk_nhan_id, v_so_du_nhan, v_so_du_nhan + p_so_tien);

    -- 7. Ghi giao dịch
    v_ma_gd := 'GD_' || EXTRACT(EPOCH FROM now());

    INSERT INTO GiaoDich(
        ma_gd,
        tai_khoan_id,
        loai_gd,
        so_tien,
        tai_khoan_doi_tac,
        noi_dung,
        trang_thai
    )
    VALUES
        (v_ma_gd, v_tk_gui_id, 'CHUYEN_TIEN', p_so_tien, v_tk_nhan_id, p_noi_dung, 'SUCCESS'),
        (v_ma_gd, v_tk_nhan_id, 'CHUYEN_TIEN', p_so_tien, v_tk_gui_id, p_noi_dung, 'SUCCESS');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
$$;

--
CREATE OR REPLACE PROCEDURE thong_tin_tai_khoan(

    p_ma_tk VARCHAR,

    OUT p_ho_ten VARCHAR,

    OUT p_so_du DECIMAL,

    OUT p_so_giao_dich INTEGER

)
LANGUAGE plpgsql
as $$
begin
	select kh.ho_ten, tk.so_du into p_ho_ten,p_so_du
	from taikhoan tk join khachhang kh on kh.id = tk.khach_hang_id
	where tk.ma_tk=p_ma_tk;

	if not found then raise notice 'Mã tài khoản % không tồn tại',p_ma_tk;
	end if;
	--Đếm số lượng giao dịch
	select count(*) into p_so_giao_dich
	from giaodich
	where tai_khoan_id=(select id from taikhoan where ma_tk=p_ma_tk);
	
end 
$$;


--Procedure tính lãi suất với biến phức tạp:
CREATE OR REPLACE PROCEDURE tinh_lai_suat_thang(
    p_thang INTEGER,
    p_nam   INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk RECORD;
    v_lai_suat NUMERIC(5,2);
    v_tien_lai NUMERIC(15,2);
    v_so_du_cu NUMERIC(15,2);
    v_ma_gd TEXT;
BEGIN
    -- Duyệt tất cả tài khoản ACTIVE
    FOR v_tk IN
        SELECT id, so_du, loai_tk
        FROM TaiKhoan
        WHERE trang_thai = 'ACTIVE'
    LOOP
        -- Bỏ qua tài khoản số dư <= 0
        IF v_tk.so_du <= 0 THEN
            CONTINUE;
        END IF;

        -- Xác định lãi suất theo loại tài khoản
        IF v_tk.loai_tk = 'THUONG' THEN
            v_lai_suat := 6; -- 6% / năm
        ELSE
            v_lai_suat := 5; -- mặc định
        END IF;

        -- Lưu số dư cũ
        v_so_du_cu := v_tk.so_du;

        -- Tính tiền lãi tháng
        v_tien_lai := v_tk.so_du * (v_lai_suat / 100) / 12;

        -- Cập nhật số dư tài khoản
        UPDATE TaiKhoan
        SET so_du = so_du + v_tien_lai
        WHERE id = v_tk.id;

        -- Sinh mã giao dịch
        v_ma_gd := 'LAI_' || v_tk.id || '_' || p_thang || '_' || p_nam;

        -- Ghi giao dịch
        INSERT INTO GiaoDich(
            ma_gd,
            tai_khoan_id,
            loai_gd,
            so_tien,
            noi_dung,
            trang_thai
        )
        VALUES (
            v_ma_gd,
            v_tk.id,
            'LAI_THANG',
            v_tien_lai,
            'Lãi tháng ' || p_thang || '/' || p_nam,
            'SUCCESS'
        );

        -- Ghi lịch sử số dư
        INSERT INTO LichSuSoDu(
            tai_khoan_id,
            so_du_truoc,
            so_du_sau
        )
        VALUES (
            v_tk.id,
            v_so_du_cu,
            v_so_du_cu + v_tien_lai
        );

        RAISE NOTICE 
            'TK %: +% tiền lãi tháng %/%',
            v_tk.id, v_tien_lai, p_thang, p_nam;

    END LOOP;

    RAISE NOTICE 'Hoàn tất tính lãi tháng %/%', p_thang, p_nam;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Có lỗi xảy ra, rollback toàn bộ!';
        RAISE;
END;
$$;
--PHẦN 3: ĐIỀU KIỆN & LOGIC PHỨC TẠP
--Procedure phân loại khách hàng:

CREATE OR REPLACE PROCEDURE phan_loai_khach_hang()
LANGUAGE plpgsql
AS $$
DECLARE
    v_kh RECORD;
    v_tong_so_du NUMERIC(15,2);
    v_loai TEXT;
BEGIN
    -- Duyệt từng khách hàng
    FOR v_kh IN
        SELECT id, ma_kh
        FROM KhachHang
    LOOP
        -- Tính tổng số dư các tài khoản của KH
        SELECT COALESCE(SUM(so_du), 0)
        INTO v_tong_so_du
        FROM TaiKhoan
        WHERE khach_hang_id = v_kh.id
          AND trang_thai = 'ACTIVE';

        -- Phân loại
        IF v_tong_so_du > 1000000000 THEN
            v_loai := 'VIP';
        ELSIF v_tong_so_du > 100000000 THEN
            v_loai := 'GOLD';
        ELSIF v_tong_so_du > 10000000 THEN
            v_loai := 'SILVER';
        ELSE
            v_loai := 'STANDARD';
        END IF;

        -- Cập nhật loại khách hàng
        UPDATE KhachHang
        SET trang_thai = v_loai
        WHERE id = v_kh.id;

        RAISE NOTICE
            'KH % | Tổng dư: % | Loại: %',
            v_kh.ma_kh, v_tong_so_du, v_loai;
    END LOOP;

    RAISE NOTICE 'Hoàn tất phân loại khách hàng';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Có lỗi xảy ra – rollback';
        RAISE;
END;
$$;


CREATE OR REPLACE PROCEDURE ap_dung_phi_giao_dich(
    p_ma_gd VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_gd RECORD;
    v_tk RECORD;
    v_phi_co_ban NUMERIC(5,4);
    v_phi NUMERIC(15,2);
    v_he_so NUMERIC(5,2);
    v_so_du_cu NUMERIC(15,2);
    v_la_cuoi_tuan BOOLEAN;
    v_ma_gd_phi TEXT;
BEGIN
    -- Lấy thông tin giao dịch
    SELECT *
    INTO v_gd
    FROM GiaoDich
    WHERE ma_gd = p_ma_gd;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Giao dịch không tồn tại';
    END IF;

    -- Lấy tài khoản
    SELECT *
    INTO v_tk
    FROM TaiKhoan
    WHERE id = v_gd.tai_khoan_id
      AND trang_thai = 'ACTIVE'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản không hợp lệ';
    END IF;

    -- Xác định phí cơ bản theo loại giao dịch
    IF v_gd.loai_gd = 'CHUYEN_TIEN' THEN
        v_phi_co_ban := 0.002;
    ELSIF v_gd.loai_gd = 'RUT_TIEN' THEN
        v_phi_co_ban := 0.001;
    ELSE
        v_phi_co_ban := 0;
    END IF;

    -- Kiểm tra cuối tuần
    v_la_cuoi_tuan :=
        EXTRACT(DOW FROM v_gd.created_at) IN (0,6);

    -- Hệ số theo loại tài khoản
    IF v_tk.loai_tk = 'VIP' THEN
        v_he_so := 0.5;
    ELSE
        v_he_so := 1;
    END IF;

    -- Tính phí
    v_phi := v_gd.so_tien * v_phi_co_ban * v_he_so;

    IF v_la_cuoi_tuan THEN
        v_phi := v_phi * 1.5;
    END IF;

    -- Nếu phí = 0 thì bỏ qua
    IF v_phi <= 0 THEN
        RAISE NOTICE 'Giao dịch không bị tính phí';
        RETURN;
    END IF;

    -- Kiểm tra số dư đủ
    IF v_tk.so_du < v_phi THEN
        RAISE EXCEPTION 'Không đủ số dư để trừ phí';
    END IF;

    v_so_du_cu := v_tk.so_du;

    -- Trừ phí
    UPDATE TaiKhoan
    SET so_du = so_du - v_phi
    WHERE id = v_tk.id;

    -- Sinh mã giao dịch phí
    v_ma_gd_phi := 'PHI_' || p_ma_gd;

    -- Ghi giao dịch phí
    INSERT INTO GiaoDich(
        ma_gd,
        tai_khoan_id,
        loai_gd,
        so_tien,
        noi_dung,
        trang_thai
    )
    VALUES (
        v_ma_gd_phi,
        v_tk.id,
        'PHI_GIAO_DICH',
        v_phi,
        'Phí giao dịch cho ' || p_ma_gd,
        'SUCCESS'
    );

    -- Ghi lịch sử số dư
    INSERT INTO LichSuSoDu(
        tai_khoan_id,
        so_du_truoc,
        so_du_sau
    )
    VALUES (
        v_tk.id,
        v_so_du_cu,
        v_so_du_cu - v_phi
    );

    RAISE NOTICE
        'Đã trừ phí % cho giao dịch %',
        v_phi, p_ma_gd;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Lỗi xảy ra – rollback toàn bộ';
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE tao_sao_ke_thang(
    p_thang INTEGER,
    p_nam   INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk RECORD;
    v_gd RECORD;
    v_tu_ngay DATE;
    v_den_ngay DATE;
BEGIN
    -- Xác định khoảng thời gian tháng
    v_tu_ngay  := make_date(p_nam, p_thang, 1);
    v_den_ngay := (v_tu_ngay + INTERVAL '1 month')::DATE;

    -- Duyệt từng tài khoản
    FOR v_tk IN
        SELECT id, ma_tk
        FROM TaiKhoan
    LOOP
        RAISE NOTICE '===== SAO KÊ TK % (%/% ) =====',
            v_tk.ma_tk, p_thang, p_nam;

        -- Duyệt giao dịch của tài khoản trong tháng
        FOR v_gd IN
            SELECT loai_gd, so_tien, created_at
            FROM GiaoDich
            WHERE tai_khoan_id = v_tk.id
              AND created_at >= v_tu_ngay
              AND created_at < v_den_ngay
            ORDER BY created_at
        LOOP
            RAISE NOTICE
                '% | % | %',
                v_gd.created_at,
                v_gd.loai_gd,
                v_gd.so_tien;
        END LOOP;

    END LOOP;

    RAISE NOTICE 'Hoàn tất tạo sao kê tháng %/%', p_thang, p_nam;
END;
$$;

CREATE OR REPLACE PROCEDURE gui_tien_an_toan(
    p_ma_tk   VARCHAR,
    p_so_tien DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk RECORD;
    v_so_du_cu NUMERIC(15,2);
    v_ma_gd TEXT;
BEGIN
    -- 1. Kiểm tra số tiền hợp lệ
    IF p_so_tien IS NULL OR p_so_tien <= 0 THEN
        RAISE EXCEPTION 'Số tiền không hợp lệ';
    END IF;

    -- 2. Lấy tài khoản + khóa dòng
    SELECT *
    INTO v_tk
    FROM TaiKhoan
    WHERE ma_tk = p_ma_tk
    FOR UPDATE;

    -- 3. Kiểm tra tài khoản tồn tại
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản không tồn tại';
    END IF;

    -- 4. Kiểm tra trạng thái tài khoản
    IF v_tk.trang_thai <> 'ACTIVE' THEN
        RAISE EXCEPTION 'Tài khoản đã bị khóa';
    END IF;

    v_so_du_cu := v_tk.so_du;

    -- 5. Cập nhật số dư
    UPDATE TaiKhoan
    SET so_du = so_du + p_so_tien
    WHERE id = v_tk.id;

    -- 6. Sinh mã giao dịch
    v_ma_gd := 'GUI_' || v_tk.id || '_' || EXTRACT(EPOCH FROM NOW());

    -- 7. Ghi giao dịch
    INSERT INTO GiaoDich(
        ma_gd,
        tai_khoan_id,
        loai_gd,
        so_tien,
        noi_dung,
        trang_thai
    )
    VALUES (
        v_ma_gd,
        v_tk.id,
        'GUI_TIEN',
        p_so_tien,
        'Gửi tiền vào tài khoản',
        'SUCCESS'
    );

    -- 8. Ghi lịch sử số dư
    INSERT INTO LichSuSoDu(
        tai_khoan_id,
        so_du_truoc,
        so_du_sau
    )
    VALUES (
        v_tk.id,
        v_so_du_cu,
        v_so_du_cu + p_so_tien
    );

    RAISE NOTICE
        'Gửi tiền thành công | TK: % | +%',
        p_ma_tk, p_so_tien;

-- ================== EXCEPTION HANDLING ==================
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Lỗi hệ thống: %', SQLERRM;
        RAISE; -- rollback toàn bộ
END;
$$;

