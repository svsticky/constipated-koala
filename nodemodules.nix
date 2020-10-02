{ fetchurl, fetchgit, linkFarm, runCommandNoCC, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "bootstrap___bootstrap_4.3.1.tgz";
      path = fetchurl {
        name = "bootstrap___bootstrap_4.3.1.tgz";
        url  = "https://registry.yarnpkg.com/bootstrap/-/bootstrap-4.3.1.tgz";
        sha1 = "280ca8f610504d99d7b6b4bfc4b68cec601704ac";
      };
    }
    {
      name = "clipboard___clipboard_1.7.1.tgz";
      path = fetchurl {
        name = "clipboard___clipboard_1.7.1.tgz";
        url  = "https://registry.yarnpkg.com/clipboard/-/clipboard-1.7.1.tgz";
        sha1 = "360d6d6946e99a7a1fef395e42ba92b5e9b5a16b";
      };
    }
    {
      name = "delegate___delegate_3.2.0.tgz";
      path = fetchurl {
        name = "delegate___delegate_3.2.0.tgz";
        url  = "https://registry.yarnpkg.com/delegate/-/delegate-3.2.0.tgz";
        sha1 = "b66b71c3158522e8ab5744f720d8ca0c2af59166";
      };
    }
    {
      name = "good_listener___good_listener_1.2.2.tgz";
      path = fetchurl {
        name = "good_listener___good_listener_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/good-listener/-/good-listener-1.2.2.tgz";
        sha1 = "d53b30cdf9313dffb7dc9a0d477096aa6d145c50";
      };
    }
    {
      name = "intl_tel_input___intl_tel_input_16.0.5.tgz";
      path = fetchurl {
        name = "intl_tel_input___intl_tel_input_16.0.5.tgz";
        url  = "https://registry.yarnpkg.com/intl-tel-input/-/intl-tel-input-16.0.5.tgz";
        sha1 = "d02431473a1eecec297cbb416cdd3e80432ec075";
      };
    }
    {
      name = "jquery_ujs___jquery_ujs_1.2.2.tgz";
      path = fetchurl {
        name = "jquery_ujs___jquery_ujs_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/jquery-ujs/-/jquery-ujs-1.2.2.tgz";
        sha1 = "6a8ef1020e6b6dda385b90a4bddc128c21c56397";
      };
    }
    {
      name = "jquery___jquery_3.5.0.tgz";
      path = fetchurl {
        name = "jquery___jquery_3.5.0.tgz";
        url  = "https://registry.yarnpkg.com/jquery/-/jquery-3.5.0.tgz";
        sha1 = "9980b97d9e4194611c36530e7dc46a58d7340fc9";
      };
    }
    {
      name = "jquery___jquery_3.5.1.tgz";
      path = fetchurl {
        name = "jquery___jquery_3.5.1.tgz";
        url  = "https://registry.yarnpkg.com/jquery/-/jquery-3.5.1.tgz";
        sha1 = "d7b4d08e1bfdb86ad2f1a3d039ea17304717abb5";
      };
    }
    {
      name = "js_cookie___js_cookie_2.2.1.tgz";
      path = fetchurl {
        name = "js_cookie___js_cookie_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/js-cookie/-/js-cookie-2.2.1.tgz";
        sha1 = "69e106dc5d5806894562902aa5baec3744e9b2b8";
      };
    }
    {
      name = "select___select_1.1.2.tgz";
      path = fetchurl {
        name = "select___select_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/select/-/select-1.1.2.tgz";
        sha1 = "0e7350acdec80b1108528786ec1d4418d11b396d";
      };
    }
    {
      name = "sweetalert2___sweetalert2_9.14.2.tgz";
      path = fetchurl {
        name = "sweetalert2___sweetalert2_9.14.2.tgz";
        url  = "https://registry.yarnpkg.com/sweetalert2/-/sweetalert2-9.14.2.tgz";
        sha1 = "c5f39b0eae5e795c22e90d62b38f2f7d4a019277";
      };
    }
    {
      name = "tiny_emitter___tiny_emitter_2.1.0.tgz";
      path = fetchurl {
        name = "tiny_emitter___tiny_emitter_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/tiny-emitter/-/tiny-emitter-2.1.0.tgz";
        sha1 = "1d1a56edfc51c43e863cbb5382a72330e3555423";
      };
    }
    {
      name = "toastr___toastr_2.1.4.tgz";
      path = fetchurl {
        name = "toastr___toastr_2.1.4.tgz";
        url  = "https://registry.yarnpkg.com/toastr/-/toastr-2.1.4.tgz";
        sha1 = "8b43be64fb9d0c414871446f2db8e8ca4e95f181";
      };
    }
    {
      name = "turbolinks___turbolinks_5.2.0.tgz";
      path = fetchurl {
        name = "turbolinks___turbolinks_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/turbolinks/-/turbolinks-5.2.0.tgz";
        sha1 = "e6877a55ea5c1cb3bb225f0a4ae303d6d32ff77c";
      };
    }
  ];
}
