// Surety 表单校验
.pragma library

function isValidEmail(email) {
    return email && email.indexOf("@") > 0 && email.indexOf(".", email.indexOf("@")) > email.indexOf("@") + 1
}

function isValidPassword(pwd) {
    return pwd && pwd.length >= 6 && pwd.length <= 20 && pwd.indexOf(" ") < 0
           && /[a-zA-Z]/.test(pwd) && /[0-9]/.test(pwd)
}

function passwordsMatch(a, b) {
    return a && a === b
}

function isNotEmpty(s) {
    return s && s.trim() !== ""
}
