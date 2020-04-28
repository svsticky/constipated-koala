//= require i18n
//= require i18n/translations

// Language logic
I18n.fallbacks = true;
I18n.defaultLocale = "nl";
I18n.locale = sessionStorage.getItem("locale");

// Language switcher
const urlParams = new URLSearchParams(window.location.search);
const language = urlParams.get('l');

if (language != null) {
  console.log(language)
  const l = language || sessionStorage.getItem("locale") || I18n.defaultLocale
  sessionStorage.setItem("locale", l);
  I18n.locale = l;
  window.location = window.location.pathname;
}