<?php

namespace Drupal\poms_lang_display;

class PomsLangDisplayConstants {
    // Libraries and modules websites.
    const LANGDROPDOWN_CHOSEN_WEB_URL = 'http://harvesthq.github.com/chosen';
    const LANGDROPDOWN_CHOSEN_MOD_URL = 'https://drupal.org/project/chosen';
    const LANGDROPDOWN_MSDROPDOWN_URL = 'https://github.com/marghoobsuleman/ms-Dropdown';
    const LANGDROPDOWN_LANGUAGEICONS_MOD_URL = 'https://drupal.org/project/languageicons';
    const LANGDROPDOWN_DDSLICK_WEB_URL = 'http://designwithpc.com/Plugins/ddSlick';

    // Language display options.
    const LANGDROPDOWN_DISPLAY_TRANSLATED = 0;
    const LANGDROPDOWN_DISPLAY_NATIVE = 1;
    const LANGDROPDOWN_DISPLAY_LANGCODE = 2;
    const LANGDROPDOWN_DISPLAY_SELFTRANSLATED = 3;

    // Widget styles.
    const LANGDROPDOWN_SIMPLE_SELECT = 0;
    const LANGDROPDOWN_MSDROPDOWN = 1;
    const LANGDROPDOWN_CHOSEN = 2;
    const LANGDROPDOWN_DDSLICK = 3;

    // Flag position.
    const LANGDROPDOWN_FLAG_POSITION_BEFORE = 0;
    const LANGDROPDOWN_FLAG_POSITION_AFTER = 1;

    // Image position in ddslick.
    const LANGDROPDOWN_DDSLICK_LEFT = 'left';
    const LANGDROPDOWN_DDSLICK_RIGHT = 'right';
}
