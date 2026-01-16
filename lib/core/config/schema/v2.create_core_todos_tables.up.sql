-- ================================================= SCHEMA =================================================
-- 1. Tạo enums
CREATE TYPE public.todo_priority AS ENUM ('low', 'medium', 'high', 'urgent');

CREATE TYPE public.todo_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);

CREATE TYPE public.recurrence_pattern AS ENUM ('none', 'daily', 'weekly', 'monthly', 'yearly');

CREATE TYPE public.attachment_file_extension AS ENUM (
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'pdf',
    'doc',
    'docx',
    'other'
);

-- 2. Tạo bảng
CREATE TABLE
    "public"."projects" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '', -- Hex color
        "is_archived" BOOLEAN NOT NULL DEFAULT FALSE,
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

CREATE TABLE
    "public"."todos" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "project_id" UUID REFERENCES public.projects (id) ON DELETE SET NULL,
        "title" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "priority" todo_priority NOT NULL DEFAULT 'low',
        "status" todo_status NOT NULL DEFAULT 'pending',
        "started_date" timestamptz,
        "due_date" timestamptz,
        "reminder_at" timestamptz DEFAULT NULL,
        "completed_at" timestamptz DEFAULT NULL,
        "recurrence_pattern" recurrence_pattern DEFAULT 'none',
        "parent_todo_id" UUID REFERENCES public.todos (id) ON DELETE CASCADE,
        "position" INTEGER NOT NULL DEFAULT 0,
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

CREATE TABLE
    "public"."tags" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(64) NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '', -- Hex color
        "created_at" timestamptz NOT NULL DEFAULT now ()
    );

CREATE TABLE
    "public"."todo_tags" (
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        "tag_id" UUID NOT NULL REFERENCES public.tags (id) ON DELETE CASCADE,
        PRIMARY KEY ("todo_id", "tag_id")
    );

CREATE TABLE
    "public"."attachments" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        "file_name" VARCHAR(256) NOT NULL DEFAULT '',
        "file_url" TEXT NOT NULL DEFAULT '',
        "file_extension" attachment_file_extension NOT NULL DEFAULT 'other',
        "file_size" BIGINT DEFAULT 0,
        "uploaded_at" timestamptz NOT NULL DEFAULT now ()
    );

-- ================================================= INDEXES =================================================
-- Projects
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON public.projects (user_id);

CREATE INDEX IF NOT EXISTS idx_projects_active ON public.projects (user_id)
WHERE
    is_archived = FALSE;

-- Todos
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos (user_id);

CREATE INDEX IF NOT EXISTS idx_todos_project_id ON public.todos (project_id);

CREATE INDEX IF NOT EXISTS idx_todos_parent_id ON public.todos (parent_todo_id);

CREATE INDEX IF NOT EXISTS idx_todos_user_status ON public.todos (user_id, status);

CREATE INDEX IF NOT EXISTS idx_todos_user_due_date ON public.todos (user_id, due_date);

CREATE INDEX IF NOT EXISTS idx_todos_project_position ON public.todos (project_id, position);

-- Index cho sắp xếp
CREATE INDEX IF NOT EXISTS idx_todos_project_position ON public.todos (project_id, position);

-- Tags
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_user_name ON public.tags (user_id, name);

-- Todo_Tags & Attachments
CREATE INDEX IF NOT EXISTS idx_todo_tags_tag_id ON public.todo_tags (tag_id);

CREATE INDEX IF NOT EXISTS idx_attachments_todo_id ON public.attachments (todo_id);

-- ================================================= COMMENTS =================================================
-- PROJECTS
COMMENT ON TABLE public.projects IS 'Quản lý các dự án hoặc nhóm công việc lớn.';

COMMENT ON COLUMN public.projects.is_archived IS 'Đánh dấu dự án đã hoàn thành hoặc lưu trữ, ẩn khỏi danh sách chính.';

-- TODOS
COMMENT ON TABLE public.todos IS 'Bảng chứa dữ liệu công việc chính (Task). Hỗ trợ đệ quy cho subtask.';

COMMENT ON COLUMN public.todos.project_id IS 'FK nối tới Projects. NULL nghĩa là công việc thuộc Inbox/Chung.';

COMMENT ON COLUMN public.todos.parent_todo_id IS 'Dùng cho Subtasks (công việc con).';

COMMENT ON COLUMN public.todos.position IS 'Số thứ tự dùng để sắp xếp công việc (hữu ích cho Kanban board hoặc danh sách tuỳ chỉnh).';

COMMENT ON COLUMN public.todos.recurrence_pattern IS 'Quy tắc lặp lại công việc (hàng ngày, tuần...).';

-- TAGS
COMMENT ON TABLE public.tags IS 'Nhãn dán (Labels) để đánh dấu chéo giữa các project.';

COMMENT ON COLUMN public.tags.name IS 'Tên nhãn, duy nhất trong phạm vi mỗi user.';

-- ATTACHMENTS
COMMENT ON TABLE public.attachments IS 'Lưu trữ thông tin file đính kèm cho công việc.';

COMMENT ON COLUMN public.attachments.file_url IS 'Đường dẫn tới file (thường là link Storage Bucket).';

COMMENT ON COLUMN public.attachments.file_extension IS 'Phần mở rộng của file để hiển thị icon phù hợp (vd: jpg, pdf).';

-- ================================================= RLS & SECURITY =================================================
-- Bật RLS cho tất cả bảng vừa tạo (Quan trọng!)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todo_tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- ================================================= AUTOMATION (TRIGGERS) =================================================
-- 1. Auto-update "updated_at" timestamp
-- Cần extension này
CREATE EXTENSION IF NOT EXISTS moddatetime SCHEMA extensions;

CREATE TRIGGER handle_updated_at_projects BEFORE
UPDATE ON public.projects FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

CREATE TRIGGER handle_updated_at_todos BEFORE
UPDATE ON public.todos FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

-- 2. SEED DEFAULT TAGS (LOGIC BẠN YÊU CẦU) 
-- Function tạo 10 tags mẫu cho user mới
CREATE
OR REPLACE FUNCTION public.seed_default_tags () RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER
SET
    search_path = public AS BEGIN
    -- Chèn 10 tags với màu sắc hiện đại (dùng bảng màu Tailwind/Pastel)
INSERT INTO
    public.tags (user_id, name, color)
VALUES
    (new.id, 'Chưa đặt tên', '#EF4444'), -- Đỏ (Urgent)
    (new.id, 'Chưa đặt tên', '#3B82F6'), -- Xanh dương (Work)
    (new.id, 'Chưa đặt tên', '#10B981'), -- Xanh lá (Personal)
    (new.id, 'Chưa đặt tên', '#F59E0B'), -- Vàng cam (Study)
    (new.id, 'Chưa đặt tên', '#EC4899'), -- Hồng (Health)
    (new.id, 'Chưa đặt tên', '#8B5CF6'), -- Tím (Finance)
    (new.id, 'Chưa đặt tên', '#14B8A6'), -- Teal (Family)
    (new.id, 'Chưa đặt tên', '#84CC16'), -- Lime (Entertainment)
    (new.id, 'Chưa đặt tên', '#F97316'), -- Cam (Shopping)
    (new.id, 'Chưa đặt tên', '#06B6D4');

-- Cyan (Travel)
RETURN new;

END;

-- Tạo Trigger gắn vào bảng auth.users
-- Lưu ý: Một bảng (auth.users) có thể có nhiều trigger. 
-- Trigger ở V1 tạo profile, Trigger này ở V2 tạo tags. Cả 2 sẽ chạy khi user đăng ký.
CREATE TRIGGER on_auth_user_created_seed_tags AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.seed_default_tags ();