-- ================================================= DOWN MIGRATION =================================================

-- 1. Xóa trigger trên auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. Xóa function handle_new_user
DROP FUNCTION IF EXISTS public.handle_new_user ();

-- 3. Xóa function check email
DROP FUNCTION IF EXISTS public.check_email_exists (TEXT);

-- 4. Xóa policy RLS
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

-- 5. Tắt RLS (không bắt buộc nhưng nên làm trước khi drop table)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 6. Xóa bảng profiles
DROP TABLE IF EXISTS public.profiles;

-- 7. Xóa enum sex
DROP TYPE IF EXISTS public.sex;

-- ================================================= END DOWN =================================================