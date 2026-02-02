<?php

namespace Drupal\Tests\lang_dropdown\Functional;

use Drupal\Core\Language\LanguageInterface;
use Drupal\Tests\BrowserTestBase;

/**
 * Functional tests for the language switching feature.
 *
 * @group lang_dropdown
 */
class LanguageSwitchingTest extends BrowserTestBase {

  /**
   * {@inheritdoc}
   */
  protected $defaultTheme = 'stable';

  /**
   * {@inheritdoc}
   */
  protected static $modules = [
    'block',
    'language',
    'poms_lang_display',
    'locale',
  ];

  /**
   * {@inheritdoc}
   */
  protected function setUp(): void {
    parent::setUp();

    // Create and log in user.
    $admin_user = $this->createUser([
      'administer blocks',
      'administer languages',
      'access administration pages',
    ]);
    $this->drupalLogin($admin_user);
  }

  /**
   * Tests language switcher links for session based negotiation.
   */
  public function testLanguageSessionSwitchLinks() {
    // Add language.
    $edit = [
      'predefined_langcode' => 'fr',
    ];
    $this->drupalGet('admin/config/regional/language/add');
    $this->submitForm($edit, t('Add language'));

    // Enable session language detection and selection.
    $edit = [
      'language_interface[enabled][language-url]' => FALSE,
      'language_interface[enabled][language-session]' => TRUE,
    ];
    $this->drupalGet('admin/config/regional/language/detection');
    $this->submitForm($edit, t('Save settings'));

    // Enable the language switching block.
    $this->placeBlock('language_dropdown_block:' . LanguageInterface::TYPE_INTERFACE, [
      'id' => 'test_language_dropdown_block',
      'showall' => 1,
      'hide_only_one' => 0,
    ]);

    // Go to the homepage.
    $this->drupalGet('');
    // Make sure default language selected is English.
    $this->assertEquals(1, count($this->cssSelect('#edit-poms-lang-display-select option[selected=selected]:contains(English)')));
    // Go to the homepage for French language.
    $this->drupalGet('', ['query' => ['language' => 'fr']]);
    // Make sure default language selected is French.
    $this->assertEquals(1, count($this->cssSelect('#edit-poms-lang-display-select option[selected=selected]:contains(French)')));
    // @todo Add Ajax testing of language switching.
  }

}
