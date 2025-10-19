module.exports = {
  extends: ["turbo", "eslint:recommended"],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "react"],
  rules: {
    "react/jsx-key": "off",
  },
};
