-- ================================================= SCHEMA =================================================

-- Giữ nguyên Enum cũ
CREATE TYPE public.user_sex AS ENUM ('female', 'male');
-- Bỏ enum "sources" vì auth.users tự quản lý provider (google/facebook/email)

-- Tạo bảng Profiles để chứa thông tin người dùng
-- Lưu ý: id của bảng này chính là id của auth.users
CREATE TABLE "public"."profiles" (
    "id" uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    "full_name" varchar(64) NOT NULL DEFAULT '',
    "date_of_birth" date NOT NULL,
    "sex" public.user_sex DEFAULT 'male'::public.user_sex,
    "avatar_url" text NOT NULL DEFAULT '',
    "created_at" timestamptz NOT NULL DEFAULT (now()),
    "updated_at" timestamptz NOT NULL DEFAULT (now()),
    
    PRIMARY KEY ("id")
);

-- ================================================= END =================================================
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ================================================= POLICY =================================================

-- Bật RLS (Bảo mật dòng dữ liệu)
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

-- Tạo chính sách: Ai xem được profile của người đó
CREATE POLICY "Users can view own profile" 
ON "public"."profiles" 
FOR SELECT 
USING (auth.uid() = id);

-- Tạo chính sách: Ai sửa được profile của người đó
CREATE POLICY "Users can update own profile" 
ON "public"."profiles" 
FOR UPDATE 
USING (auth.uid() = id);

-- ================================================= END =================================================
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ================================================= FUNCTION =================================================

-- Hàm xử lý khi có user mới
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url, date_of_birth, sex)
    VALUES (
        new.id, 
        -- Lấy dữ liệu từ meta_data được gửi từ phía Client
        new.raw_user_meta_data ->> 'full_name',
        new.raw_user_meta_data ->> 'avatar_url',
        (new.raw_user_meta_data ->> 'dob')::date,   -- Cast text sang date
        (new.raw_user_meta_data ->> 'sex')::sex     -- Cast text sang enum sex
    );
    RETURN new;
END;
$$;

-- Gán Trigger vào bảng auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Hàm dùng để kiểm tra email đã tồn tại trong bảng auth.users hay chưa
-- Trả về true nếu email đã tồn tại, ngược lại trả về false
-- Sử dụng security definer để chạy với quyền admin (phù hợp cho RLS / Supabase)
CREATE OR REPLACE FUNCTION PUBLIC.CHECK_EMAIL_EXISTS(EMAIL_CHECK TEXT)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
SECURITY DEFINER
SET SEARCH_PATH = PUBLIC
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM AUTH.USERS
        WHERE EMAIL = EMAIL_CHECK
    );
END;
$$;

-- ================================================= END =================================================
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\