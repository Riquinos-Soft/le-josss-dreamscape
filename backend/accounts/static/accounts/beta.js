"use strict";

document.getElementById("use-beta").addEventListener("click", () => {
  document.getElementById("id_email").value = "beta";
  document.getElementById("id_password").value = "beta";
  document.querySelector(".credentials button[type=submit]").focus();
});
