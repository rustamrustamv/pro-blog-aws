module.exports = {
  content: [
    "./client/templates/**/*.html", // all your HTML templates
    "./app/**/*.py",                // if Flask/Django renders classes from Python
    "./**/*.js"                     // if you generate classes in JS
  ],
  theme: { extend: {} },
  plugins: []
};