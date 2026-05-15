import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const standaloneNodeModules = existsSync(
  join(__dirname, "node_modules/next/package.json"),
);
const turbopackRoot = standaloneNodeModules ? __dirname : join(__dirname, "../..");

/** @type {import("next").NextConfig} */
const nextConfig = {
  poweredByHeader: false,
  reactStrictMode: true,
  turbopack: {
    root: turbopackRoot,
  },
};

export default nextConfig;
