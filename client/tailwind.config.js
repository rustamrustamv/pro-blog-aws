// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./client/templates/**/*.html",
    "./app/**/*.py", // if using Flask/Django
  ],
  theme: { extend: {} },
  plugins: [],
};