import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react({
      include: ["**/*.res.mjs"],
    }),
  ],
  server: {
    proxy: {
      '/backend': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      }
    }
  }
});
