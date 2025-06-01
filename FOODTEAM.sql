USE [master]
GO
/****** Object:  Database [FOODTEAM]    Script Date: 5/30/2025 8:27:01 PM ******/
CREATE DATABASE [FOODTEAM]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FOODTEAM', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\FOODTEAM.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'FOODTEAM_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\FOODTEAM_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [FOODTEAM] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FOODTEAM].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FOODTEAM] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FOODTEAM] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FOODTEAM] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FOODTEAM] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FOODTEAM] SET ARITHABORT OFF 
GO
ALTER DATABASE [FOODTEAM] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [FOODTEAM] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FOODTEAM] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FOODTEAM] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FOODTEAM] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FOODTEAM] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FOODTEAM] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FOODTEAM] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FOODTEAM] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FOODTEAM] SET  ENABLE_BROKER 
GO
ALTER DATABASE [FOODTEAM] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FOODTEAM] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FOODTEAM] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FOODTEAM] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FOODTEAM] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FOODTEAM] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FOODTEAM] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FOODTEAM] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FOODTEAM] SET  MULTI_USER 
GO
ALTER DATABASE [FOODTEAM] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FOODTEAM] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FOODTEAM] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FOODTEAM] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [FOODTEAM] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [FOODTEAM] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [FOODTEAM] SET QUERY_STORE = ON
GO
ALTER DATABASE [FOODTEAM] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [FOODTEAM]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[food_items]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[food_items](
	[foodid] [int] IDENTITY(1,1) NOT NULL,
	[anh] [nvarchar](255) NULL,
	[description] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[price] [numeric](38, 3) NULL,
	[categoryid] [int] NULL,
	[quantity] [int] NULL,
 CONSTRAINT [PK__food_ite__77E7E631F93B1B59] PRIMARY KEY CLUSTERED 
(
	[foodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodItems]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodItems](
	[FoodID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Price] [decimal](10, 3) NOT NULL,
	[Anh] [nvarchar](1) NOT NULL,
	[CategoryID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[FoodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[inventory_logs]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[inventory_logs](
	[logid] [int] IDENTITY(1,1) NOT NULL,
	[change_quantity] [int] NULL,
	[created_at] [datetime2](6) NULL,
	[note] [nvarchar](255) NULL,
	[created_by] [int] NULL,
	[foodid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryLogs]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryLogs](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[FoodID] [int] NULL,
	[ChangeQuantity] [int] NOT NULL,
	[Note] [nvarchar](255) NULL,
	[CreatedBy] [int] NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[invoices]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoices](
	[invoiceid] [int] IDENTITY(1,1) NOT NULL,
	[issued_at] [datetime2](6) NULL,
	[total_amount] [numeric](38, 3) NULL,
	[issued_by] [int] NULL,
	[orderid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[invoiceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[order_details]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[order_details](
	[order_detailid] [int] IDENTITY(1,1) NOT NULL,
	[price_at_order_time] [numeric](38, 3) NULL,
	[quantity] [int] NULL,
	[foodid] [int] NULL,
	[orderid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[order_detailid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[orders]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orders](
	[orderid] [int] IDENTITY(1,1) NOT NULL,
	[created_at] [datetime2](6) NULL,
	[status] [varchar](255) NULL,
	[created_by] [int] NULL,
	[tableid] [int] NULL,
	[full_name] [nvarchar](255) NULL,
	[phone] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[orderid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[table_details]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[table_details](
	[table_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[quantity] [int] NULL,
	[total_price] [numeric](38, 3) NULL,
	[foodid] [int] NULL,
	[tableid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[table_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tables]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tables](
	[tableid] [int] IDENTITY(1,1) NOT NULL,
	[status] [varchar](255) NULL,
	[table_number] [varchar](255) NULL,
	[employee_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[tableid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 5/30/2025 8:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[password_hash] [nvarchar](255) NOT NULL,
	[full_name] [nvarchar](100) NULL,
	[Role] [nvarchar](20) NOT NULL,
	[created_at] [datetime] NULL,
	[issued_by] [nvarchar](20) NULL,
	[avatar] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Categories] ON 

INSERT [dbo].[Categories] ([CategoryID], [Name]) VALUES (1, N'Món Chính')
INSERT [dbo].[Categories] ([CategoryID], [Name]) VALUES (2, N'Lẩu')
INSERT [dbo].[Categories] ([CategoryID], [Name]) VALUES (3, N'Đồ Uống')
INSERT [dbo].[Categories] ([CategoryID], [Name]) VALUES (4, N'Tráng miệng')
INSERT [dbo].[Categories] ([CategoryID], [Name]) VALUES (5, N'Món thêm')
SET IDENTITY_INSERT [dbo].[Categories] OFF
GO

SET IDENTITY_INSERT [dbo].[tables] ON 

INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (1, N'Trong', N'Bàn 1', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (2, N'Trong', N'Bàn 2', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (3, N'Trong', N'Bàn 3', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (4, N'Trong', N'Bàn 4', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (5, N'Trong', N'Bàn 5', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (6, N'Trong', N'Bàn 6', NULL)
INSERT [dbo].[tables] ([tableid], [status], [table_number], [employee_id]) VALUES (7, N'Trong', N'Bàn 7', NULL)
SET IDENTITY_INSERT [dbo].[tables] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserID], [Username], [password_hash], [full_name], [Role], [created_at], [issued_by], [avatar]) VALUES (1, N'admin', N'$2a$12$HSyAST5RoPIbyMNU0jsxROmOyA.2o9XWJ9yEyYsEZqSKvkXI/ulzO', N'Admin', N'QuanLy', CAST(N'2025-05-17T09:40:46.870' AS DateTime), NULL, N'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg')
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
/****** Object:  Index [UK13xl227cagu41rrp33793lol7]    Script Date: 5/30/2025 8:27:01 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UK13xl227cagu41rrp33793lol7] ON [dbo].[invoices]
(
	[orderid] ASC
)
WHERE ([orderid] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__536C85E40208A3E9]    Script Date: 5/30/2025 8:27:01 PM ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InventoryLogs] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[food_items]  WITH CHECK ADD  CONSTRAINT [FK84b1ch8dtnige5arfqcl43hrj] FOREIGN KEY([categoryid])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[food_items] CHECK CONSTRAINT [FK84b1ch8dtnige5arfqcl43hrj]
GO
ALTER TABLE [dbo].[FoodItems]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[inventory_logs]  WITH CHECK ADD  CONSTRAINT [FK4wpkltsrgpqhuvgtn4uschhm1] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[inventory_logs] CHECK CONSTRAINT [FK4wpkltsrgpqhuvgtn4uschhm1]
GO
ALTER TABLE [dbo].[inventory_logs]  WITH CHECK ADD  CONSTRAINT [FK7onii864xha16lcubf6ujo8fr] FOREIGN KEY([foodid])
REFERENCES [dbo].[food_items] ([foodid])
GO
ALTER TABLE [dbo].[inventory_logs] CHECK CONSTRAINT [FK7onii864xha16lcubf6ujo8fr]
GO
ALTER TABLE [dbo].[InventoryLogs]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[InventoryLogs]  WITH CHECK ADD FOREIGN KEY([FoodID])
REFERENCES [dbo].[FoodItems] ([FoodID])
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [FKdfwp371skaoaabnyd2civgn81] FOREIGN KEY([issued_by])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [FKdfwp371skaoaabnyd2civgn81]
GO
ALTER TABLE [dbo].[invoices]  WITH CHECK ADD  CONSTRAINT [FKl1kfqc1dn1xndvrrxbud61hc2] FOREIGN KEY([orderid])
REFERENCES [dbo].[orders] ([orderid])
GO
ALTER TABLE [dbo].[invoices] CHECK CONSTRAINT [FKl1kfqc1dn1xndvrrxbud61hc2]
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD  CONSTRAINT [FK3ip7byllwop4jrg4jsk8qfcmi] FOREIGN KEY([foodid])
REFERENCES [dbo].[food_items] ([foodid])
GO
ALTER TABLE [dbo].[order_details] CHECK CONSTRAINT [FK3ip7byllwop4jrg4jsk8qfcmi]
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD  CONSTRAINT [FKh35b1ljeu4440iie9psw8a7yt] FOREIGN KEY([orderid])
REFERENCES [dbo].[orders] ([orderid])
GO
ALTER TABLE [dbo].[order_details] CHECK CONSTRAINT [FKh35b1ljeu4440iie9psw8a7yt]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FKkkyr9agou0o1svua1tyw4pwnx] FOREIGN KEY([tableid])
REFERENCES [dbo].[tables] ([tableid])
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [FKkkyr9agou0o1svua1tyw4pwnx]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FKtjwuphstqm46uffgc7l1r27a9] FOREIGN KEY([created_by])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [FKtjwuphstqm46uffgc7l1r27a9]
GO
ALTER TABLE [dbo].[table_details]  WITH CHECK ADD  CONSTRAINT [FK2m4y0ytuie8wwfv4n94ujelhh] FOREIGN KEY([foodid])
REFERENCES [dbo].[food_items] ([foodid])
GO
ALTER TABLE [dbo].[table_details] CHECK CONSTRAINT [FK2m4y0ytuie8wwfv4n94ujelhh]
GO
ALTER TABLE [dbo].[table_details]  WITH CHECK ADD  CONSTRAINT [FKg6qrfb8auhcmsm7sx694rlmf5] FOREIGN KEY([tableid])
REFERENCES [dbo].[tables] ([tableid])
GO
ALTER TABLE [dbo].[table_details] CHECK CONSTRAINT [FKg6qrfb8auhcmsm7sx694rlmf5]
GO
ALTER TABLE [dbo].[tables]  WITH CHECK ADD  CONSTRAINT [FK3i6sudocrudt5h7rymrs308ll] FOREIGN KEY([employee_id])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[tables] CHECK CONSTRAINT [FK3i6sudocrudt5h7rymrs308ll]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Role]='QuanLy' OR [Role]='NhanVien'))
GO
USE [master]
GO
ALTER DATABASE [FOODTEAM] SET  READ_WRITE 
GO
