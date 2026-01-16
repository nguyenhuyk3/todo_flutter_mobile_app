-- ================================================= CLEANUP AUTOMATION =================================================
-- 1. Gỡ bỏ Trigger trên bảng auth.users
-- Đây là bước quan trọng nhất vì auth.users là bảng hệ thống, nếu không gỡ trigger, nó sẽ lỗi khi file up chạy lại.
DROP TRIGGER IF EXISTS on_auth_user_created_seed_tags ON auth.users;

-- 2. Xóa Function seeder
DROP FUNCTION IF EXISTS public.seed_default_tags ();

-- Lưu ý: Chúng ta không drop extension "moddatetime" vì có thể các migration khác (ví dụ V1 profiles) cũng đang dùng nó.
-- Triggers "handle_updated_at_..." trên các bảng projects/todos sẽ tự động biến mất khi bảng bị xóa.
-- ================================================= DROP TABLES =================================================
-- Xóa bảng theo thứ tự ngược lại lúc tạo (từ bảng phụ thuộc -> bảng chính)
-- Sử dụng CASCADE để đảm bảo xóa sạch các khóa ngoại (FK) và Index liên quan.
DROP TABLE IF EXISTS public.attachments CASCADE;

DROP TABLE IF EXISTS public.todo_tags CASCADE;

DROP TABLE IF EXISTS public.tags CASCADE;

DROP TABLE IF EXISTS public.todos CASCADE;

DROP TABLE IF EXISTS public.projects CASCADE;

-- ================================================= DROP TYPES (ENUMS) =================================================
-- Xóa các kiểu dữ liệu enum đã tạo
DROP TYPE IF EXISTS public.attachment_file_extension;

DROP TYPE IF EXISTS public.recurrence_pattern;

DROP TYPE IF EXISTS public.todo_status;

DROP TYPE IF EXISTS public.todo_priority;