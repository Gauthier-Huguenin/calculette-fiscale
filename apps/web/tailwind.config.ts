import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
      },
      colors: {
        ink: "#f7f7f5",
        coal: "#090908",
        panel: "#141310",
        line: "#2a2822",
        gold: "#f4b23a",
        sage: "#9cc8a2",
      },
    },
  },
  plugins: [],
};

export default config;
