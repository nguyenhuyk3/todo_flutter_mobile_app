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

CREATE TYPE public.attachment_file_type AS ENUM (
    'image',
    'video',
    'audio',
    'document',
    'archive',
    'other'
);

-- 2. Tạo bảng
CREATE TABLE
    "public"."categories" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(128) NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '', -- Hex color (#RRGGBB)
        "created_at" timestamptz NOT NULL DEFAULT (now ())
    );

CREATE TABLE
    "public"."projects" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "color" VARCHAR(8) NOT NULL DEFAULT '', -- Hex color (#RRGGBB)
        "is_archived" BOOLEAN NOT NULL DEFAULT FALSE,
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

CREATE TABLE
    "public"."todos" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "project_id" UUID REFERENCES public.projects (id) ON DELETE SET NULL,
        "category_id" UUID REFERENCES public.categories (id) ON DELETE SET NULL,
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
        "color" VARCHAR(8) NOT NULL DEFAULT '', -- Hex color (#RRGGBB)
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
        "file_type" attachment_file_type NOT NULL DEFAULT 'other',
        "file_size" INTEGER DEFAULT 1,
        "uploaded_at" timestamptz NOT NULL DEFAULT now ()
    );

-- ================================================= INDEXES =================================================
-- 1. Bảng Categories
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories (user_id);

-- Đảm bảo mỗi user không có 2 category trùng tên (Logic nghiệp vụ)
CREATE UNIQUE INDEX IF NOT EXISTS idx_categories_user_name ON public.categories (user_id, name);

-- 2. Bảng Projects
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON public.projects (user_id);

-- Tối ưu khi lọc project đang hoạt động (không bị archive)
CREATE INDEX IF NOT EXISTS idx_projects_active ON public.projects (user_id)
WHERE
    is_archived = FALSE;

-- 3. Bảng Todos (Bảng nặng nhất - cần index kỹ)
-- Index cho các khoá ngoại để Join bảng nhanh hơn
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos (user_id);

CREATE INDEX IF NOT EXISTS idx_todos_project_id ON public.todos (project_id);

CREATE INDEX IF NOT EXISTS idx_todos_category_id ON public.todos (category_id);

CREATE INDEX IF NOT EXISTS idx_todos_parent_id ON public.todos (parent_todo_id);

-- Tìm subtasks
-- Composite Index cho các truy vấn phổ biến (Tìm todo theo user + status/deadline)
CREATE INDEX IF NOT EXISTS idx_todos_user_status ON public.todos (user_id, status);

CREATE INDEX IF NOT EXISTS idx_todos_user_due_date ON public.todos (user_id, due_date);

-- Index cho sắp xếp (nếu dùng Kanban board kéo thả)
CREATE INDEX IF NOT EXISTS idx_todos_project_position ON public.todos (project_id, position);

-- 4. Bảng Tags
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_user_name ON public.tags (user_id, name);

-- 5. Bảng Todo_Tags
-- Index cho chiều ngược lại (tìm tất cả todo có tag cụ thể)
CREATE INDEX IF NOT EXISTS idx_todo_tags_tag_id ON public.todo_tags (tag_id);

-- 6. Bảng Attachments
CREATE INDEX IF NOT EXISTS idx_attachments_todo_id ON public.attachments (todo_id);

-- ================================================= COMMENTS =================================================
-- CATEGORIES
COMMENT ON TABLE public.categories IS 'Lưu trữ các phân loại công việc của người dùng.';

COMMENT ON COLUMN public.categories.color IS 'Mã màu Hex hiển thị cho category (VD: #FF5733).';

-- PROJECTS
COMMENT ON TABLE public.projects IS 'Quản lý các dự án hoặc nhóm công việc lớn.';

COMMENT ON COLUMN public.projects.is_archived IS 'Đánh dấu dự án đã hoàn thành hoặc lưu trữ, ẩn khỏi danh sách chính.';

-- TODOS
COMMENT ON TABLE public.todos IS 'Bảng chứa dữ liệu công việc chính (Task). Hỗ trợ đệ quy cho subtask.';

COMMENT ON COLUMN public.todos.project_id IS 'FK nối tới Projects. NULL nghĩa là công việc thuộc Inbox/Chung.';

COMMENT ON COLUMN public.todos.category_id IS 'FK nối tới Categories.';

COMMENT ON COLUMN public.todos.parent_todo_id IS 'Dùng cho Subtasks (công việc con).';

COMMENT ON COLUMN public.todos.position IS 'Số thứ tự dùng để sắp xếp công việc (hữu ích cho Kanban board hoặc danh sách tuỳ chỉnh).';

COMMENT ON COLUMN public.todos.recurrence_pattern IS 'Quy tắc lặp lại công việc (hàng ngày, tuần...).';

COMMENT ON COLUMN public.todos.started_date IS 'Thời điểm người dùng bắt đầu làm việc.';

-- TAGS
COMMENT ON TABLE public.tags IS 'Nhãn dán (Labels) để đánh dấu chéo giữa các project.';

COMMENT ON COLUMN public.tags.name IS 'Tên nhãn, duy nhất trong phạm vi mỗi user.';

-- ATTACHMENTS
COMMENT ON TABLE public.attachments IS 'Lưu trữ thông tin file đính kèm cho công việc.';

COMMENT ON COLUMN public.attachments.file_url IS 'Đường dẫn tới file (thường là link Storage Bucket).';

COMMENT ON COLUMN public.attachments.file_type IS 'Loại file phân loại để hiển thị icon/preview phù hợp.';