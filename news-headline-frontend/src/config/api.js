/**
 * API配置文件
 * 优先从环境变量读取，本地开发时使用默认值
 * 环境变量需以 VITE_ 开头，在 .env 文件中配置
 */

// API基础URL配置
export const apiConfig = {
  // 后端API基础URL
  baseURL: import.meta.env.VITE_API_BASE_URL || '',
}

