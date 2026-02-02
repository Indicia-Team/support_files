<?php

namespace Drupal\poms_lang_display\Plugin\Block;

use Drupal\Component\Render\FormattableMarkup;
use Drupal\Core\Access\AccessResult;
use Drupal\Core\Asset\LibraryDiscoveryCollector;
use Drupal\Core\Asset\LibraryDiscoveryInterface;
use Drupal\Core\Block\BlockBase;
use Drupal\Core\Extension\ModuleHandlerInterface;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Language\LanguageManagerInterface;
use Drupal\Core\Path\PathMatcherInterface;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Drupal\Core\Session\AccountInterface;
use Drupal\Core\Url;
use Drupal\Core\Session\AccountProxyInterface;
use Drupal\Core\Form\FormBuilderInterface;
use Drupal\poms_lang_display\Form\PomsLangDisplayForm;
use Drupal\poms_lang_display\PomsLangDisplayConstants;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Drupal\Core\Cache\Cache;
use Drupal\Core\TypedData\TranslationStatusInterface;
use Drupal\user\Entity\Role;

/**
 * Provides a 'Language dropdown switcher' block.
 *
 * @Block(
 *   id = "language_dropdown_block",
 *   admin_label = @Translation("Language dropdown switcher"),
 *   category = @Translation("System"),
 *   deriver = "Drupal\poms_lang_display\Plugin\Derivative\PomsLangDisplayBlock"
 * )
 */
class PomsLangDisplayBlock extends BlockBase implements ContainerFactoryPluginInterface {

  /**
   * The language manager.
   *
   * @var \Drupal\Core\Language\LanguageManagerInterface
   */
  protected $languageManager;

  /**
   * The path matcher.
   *
   * @var \Drupal\Core\Path\PathMatcherInterface
   */
  protected $pathMatcher;

  /**
   * The module handler.
   *
   * @var \Drupal\Core\Extension\ModuleHandlerInterface
   */
  protected $moduleHandler;

  /**
   * The library discovery collector service.
   *
   * @var \Drupal\Core\Asset\LibraryDiscoveryCollector
   */
  protected $libraryDiscoveryCollector;

  /**
   * The library discovery service.
   *
   * @var \Drupal\Core\Asset\LibraryDiscoveryInterface
   */
  protected $libraryDiscovery;

  /**
   * The current user account.
   *
   * @var \Drupal\Core\Session\AccountProxyInterface
   */
  protected $currentUser;

  /**
   * The form builder service.
   *
   * @var \Drupal\Core\Form\FormBuilderInterface
   */
  protected $formBuilder;

  public function __construct(array $configuration, $plugin_id, $plugin_definition, LanguageManagerInterface $language_manager, PathMatcherInterface $path_matcher, ModuleHandlerInterface $module_handler, LibraryDiscoveryCollector $library_discovery_collector, LibraryDiscoveryInterface $library_discovery, AccountProxyInterface $current_user, FormBuilderInterface $form_builder) {
    parent::__construct($configuration, $plugin_id, $plugin_definition);
    $this->languageManager = $language_manager;
    $this->pathMatcher = $path_matcher;
    $this->moduleHandler = $module_handler;
    $this->libraryDiscoveryCollector = $library_discovery_collector;
    $this->libraryDiscovery = $library_discovery;
    $this->currentUser = $current_user;
    $this->formBuilder = $form_builder;
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition) {
    return new static(
      $configuration,
      $plugin_id,
      $plugin_definition,
      $container->get('language_manager'),
      $container->get('path.matcher'),
      $container->get('module_handler'),
      $container->get('library.discovery.collector'),
      $container->get('library.discovery'),
      $container->get('current_user'),
      $container->get('form_builder')
    );
  }

  /**
   * Gets a single library defined by an extension by name.
   *
   * @param string $extension
   *   The name of the extension that registered a library.
   * @param string $name
   *   The name of a registered library to retrieve.
   *
   * @return array|false
   *   The definition of the requested library, if $name was passed and it
   *   exists, otherwise FALSE.
   */
  protected function getLibraryByName($extension, $name) {
    if (method_exists($this->libraryDiscoveryCollector, 'getLibraryByName')) {
      return $this->libraryDiscoveryCollector->getLibraryByName($extension, $name);
    }
    elseif (method_exists($this->libraryDiscovery, 'getLibraryByName')) {
      return $this->libraryDiscovery->getLibraryByName($extension, $name);
    }

    return FALSE;
  }

  /**
   * {@inheritdoc}
   */
  public function defaultConfiguration() {
    return [
      'showall' => 0,
      'hide_only_one' => 1,
      'tohome' => 0,
      'width' => 165,
      'display' => PomsLangDisplayConstants::LANGDROPDOWN_DISPLAY_NATIVE,
      'widget' => PomsLangDisplayConstants::LANGDROPDOWN_SIMPLE_SELECT,
      'msdropdown' => [
        'visible_rows' => 5,
        'rounded' => 1,
        'animation' => 'slideDown',
        'event' => 'click',
        'skin' => 'ldsSkin',
        'custom_skin' => '',
      ],
      'chosen' => [
        'disable_search' => 1,
        'no_results_text' => $this->t('No language match'),
      ],
      'ddslick' => [
        'ddslick_height' => 0,
        'showSelectedHTML' => 1,
        'imagePosition' => PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK_LEFT,
        'skin' => 'ddsDefault',
        'custom_skin' => '',
      ],
      'languageicons' => [
        'flag_position' => PomsLangDisplayConstants::LANGDROPDOWN_FLAG_POSITION_AFTER,
      ],
      'hidden_languages' => [],
    ];
  }

  /**
   * {@inheritdoc}
   */
  protected function blockAccess(AccountInterface $account) {
    $access = $this->languageManager->isMultilingual() ? AccessResult::allowed() : AccessResult::forbidden();
    return $access->addCacheTags(['config:configurable_language_list']);
  }

  /**
   * {@inheritdoc}
   */
  public function blockForm($form, FormStateInterface $form_state) {

    $form['poms_lang_display'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('Language switcher dropdown settings'),
      '#weight' => 1,
      '#tree' => TRUE,
    ];

    $form['poms_lang_display']['showall'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Show all enabled languages'),
      '#description' => $this->t('Show all languages in the switcher no matter if there is a translation for the node or not. For languages without translation the switcher will redirect to homepage.'),
      '#default_value' => $this->configuration['showall'],
    ];

    $form['poms_lang_display']['hide_only_one'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Hide if only one language is available'),
      '#description' => $this->t('If only a single language is available, go ahead and hide the block'),
      '#default_value' => $this->configuration['hide_only_one'],
    ];

    $form['poms_lang_display']['tohome'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Redirect to home on switch'),
      '#description' => $this->t('When you change language the switcher will redirect to homepage.'),
      '#default_value' => $this->configuration['tohome'],
    ];

    $form['poms_lang_display']['width'] = [
      '#type' => 'number',
      '#title' => $this->t('Width of dropdown element'),
      '#size' => 8,
      '#maxlength' => 3,
      '#required' => TRUE,
      '#field_suffix' => 'px',
      '#default_value' => $this->configuration['width'],
    ];

    $form['poms_lang_display']['display'] = [
      '#type' => 'select',
      '#title' => $this->t('Display format'),
      '#options' => [
        PomsLangDisplayConstants::LANGDROPDOWN_DISPLAY_TRANSLATED => $this->t('Translated into Current Language'),
        PomsLangDisplayConstants::LANGDROPDOWN_DISPLAY_NATIVE => $this->t('Language Native Name'),
        PomsLangDisplayConstants::LANGDROPDOWN_DISPLAY_LANGCODE => $this->t('Language Code'),
        PomsLangDisplayConstants::LANGDROPDOWN_DISPLAY_SELFTRANSLATED => $this->t('Translated into Target Language'),
      ],
      '#default_value' => $this->configuration['display'],
    ];

    $form['poms_lang_display']['widget'] = [
      '#type' => 'select',
      '#title' => $this->t('Output type'),
      '#options' => [
        PomsLangDisplayConstants::LANGDROPDOWN_SIMPLE_SELECT => $this->t('Simple HTML select'),
        PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN => $this->t('Marghoob Suleman Dropdown jquery library'),
        PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN => $this->t('Chosen jquery library'),
        PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK => $this->t('ddSlick library'),
      ],
      '#default_value' => $this->configuration['widget'],
    ];

    $form['poms_lang_display']['msdropdown'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('Marghoob Suleman Dropdown Settings'),
      '#weight' => 1,
      '#states' => [
        'visible' => [
          ':input[name="settings[poms_lang_display][widget]"]' => ['value' => PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN],
        ],
      ],
    ];

    if (!$this->moduleHandler->moduleExists('languageicons')) {
      $form['poms_lang_display']['msdropdown']['#description'] = $this->t('This looks better with <a href=":link">language icons</a> module.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_LANGUAGEICONS_MOD_URL]);
    }

    $library = $this->getLibraryByName('poms_lang_display', 'ms-dropdown');
    if (!empty($library)) {
      $num_rows = [
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
      ];
      $form['poms_lang_display']['msdropdown']['visible_rows'] = [
        '#type' => 'select',
        '#title' => $this->t('Maximum number of visible rows'),
        '#options' => array_combine($num_rows, $num_rows),
        '#default_value' => $this->configuration['msdropdown']['visible_rows'],
      ];

      $form['poms_lang_display']['msdropdown']['rounded'] = [
        '#type' => 'checkbox',
        '#title' => $this->t('Rounded corners.'),
        '#default_value' => $this->configuration['msdropdown']['rounded'],
      ];

      $form['poms_lang_display']['msdropdown']['animation'] = [
        '#type' => 'select',
        '#title' => $this->t('Animation style for dropdown'),
        '#options' => [
          'slideDown' => $this->t('Slide down'),
          'fadeIn' => $this->t('Fade in'),
          'show' => $this->t('Show'),
        ],
        '#default_value' => $this->configuration['msdropdown']['animation'],
      ];

      $form['poms_lang_display']['msdropdown']['event'] = [
        '#type' => 'select',
        '#title' => $this->t('Event that opens the menu'),
        '#options' => ['click' => $this->t('Click'), 'mouseover' => $this->t('Mouse Over')],
        '#default_value' => $this->configuration['msdropdown']['event'],
      ];

      $msdSkinOptions = [];
      foreach (_poms_lang_display_get_msdropdown_skins() as $key => $value) {
        $msdSkinOptions[$key] = $value['text'];
      }
      $form['poms_lang_display']['msdropdown']['skin'] = [
        '#type' => 'select',
        '#title' => $this->t('Skin'),
        '#options' => $msdSkinOptions,
        '#default_value' => $this->configuration['msdropdown']['skin'],
      ];

      $form['poms_lang_display']['msdropdown']['custom_skin'] = [
        '#type' => 'textfield',
        '#title' => $this->t('Custom skin name'),
        '#size' => 80,
        '#maxlength' => 55,
        '#default_value' => $this->configuration['msdropdown']['custom_skin'],
        '#states' => [
          'visible' => [
            ':input[name="settings[poms_lang_display][msdropdown][skin]"]' => ['value' => 'custom'],
          ],
        ],
      ];
    }
    else {
      $form['poms_lang_display']['msdropdown']['#description'] = $this->t('You need to download the <a href=":link">Marghoob Suleman Dropdown JavaScript library</a> and extract the entire contents of the archive into the %path directory on your server.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN_URL, '%path' => 'drupal_root/libraries']);
      $form['poms_lang_display']['msdropdown']['visible_rows'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['visible_rows'],
      ];
      $form['poms_lang_display']['msdropdown']['rounded'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['rounded'],
      ];
      $form['poms_lang_display']['msdropdown']['animation'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['animation'],
      ];
      $form['poms_lang_display']['msdropdown']['event'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['event'],
      ];
      $form['poms_lang_display']['msdropdown']['skin'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['skin'],
      ];
      $form['poms_lang_display']['msdropdown']['custom_skin'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['msdropdown']['custom_skin'],
      ];
    }

    $form['poms_lang_display']['languageicons'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('Language icons settings'),
      '#weight' => 1,
      '#states' => [
        'visible' => [
          ':input[name="settings[poms_lang_display][widget]"]' => ['value' => PomsLangDisplayConstants::LANGDROPDOWN_SIMPLE_SELECT],
        ],
      ],
    ];

    if ($this->moduleHandler->moduleExists('languageicons')) {
      $form['poms_lang_display']['languageicons']['flag_position'] = [
        '#type' => 'select',
        '#title' => $this->t('Position of the flag when the dropdown is show just as a select'),
        '#options' => [
          PomsLangDisplayConstants::LANGDROPDOWN_FLAG_POSITION_BEFORE => $this->t('Before'),
          PomsLangDisplayConstants::LANGDROPDOWN_FLAG_POSITION_AFTER => $this->t('After'),
        ],
        '#default_value' => $this->configuration['languageicons']['flag_position'],
      ];
    }
    else {
      $form['poms_lang_display']['languageicons']['#description'] = $this->t('Enable <a href=":link">language icons</a> module to show a flag of the selected language before or after the select box.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_LANGUAGEICONS_MOD_URL]);
      $form['poms_lang_display']['languageicons']['flag_position'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['languageicons']['flag_position'],
      ];
    }

    $form['poms_lang_display']['chosen'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('Chosen settings'),
      '#weight' => 2,
      '#states' => [
        'visible' => [
          ':input[name="settings[poms_lang_display][widget]"]' => ['value' => PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN],
        ],
      ],
    ];

    $library = $this->getLibraryByName('poms_lang_display', 'chosen');
    if (!empty($library) && !$this->moduleHandler->moduleExists('chosen')) {
      $form['poms_lang_display']['chosen']['disable_search'] = [
        '#type' => 'checkbox',
        '#title' => $this->t('Disable search box'),
        '#default_value' => $this->configuration['chosen']['disable_search'],
      ];

      $form['poms_lang_display']['chosen']['no_results_text'] = [
        '#type' => 'textfield',
        '#title' => $this->t('No Result Text'),
        '#description' => $this->t('Text to show when no result is found on search.'),
        '#default_value' => $this->configuration['chosen']['no_results_text'],
        '#states' => [
          'visible' => [
            ':input[name="settings[poms_lang_display][chosen][disable_search]"]' => ['checked' => FALSE],
          ],
        ],
      ];
    }
    else {
      $form['poms_lang_display']['chosen']['disable_search'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['chosen']['disable_search'],
      ];
      $form['poms_lang_display']['chosen']['no_results_text'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['chosen']['no_results_text'],
      ];
      if ($this->moduleHandler->moduleExists('chosen')) {
        $form['poms_lang_display']['chosen']['#description'] = $this->t('If you are already using the !chosenmod you must just choose to output language dropdown as a simple HTML select and allow <a href=":link">Chosen module</a> to turn it into a chosen style select.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN_MOD_URL]);
      }
      else {
        $form['poms_lang_display']['chosen']['#description'] = $this->t('You need to download the <a href=":link">Chosen library</a> and extract the entire contents of the archive into the %path directory on your server.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN_WEB_URL, '%path' => 'drupal_root/libraries']);
      }
    }

    $form['poms_lang_display']['ddslick'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('ddSlick settings'),
      '#weight' => 3,
      '#states' => [
        'visible' => [
          ':input[name="settings[poms_lang_display][widget]"]' => ['value' => PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK],
        ],
      ],
    ];

    $library = $this->getLibraryByName('poms_lang_display', 'ddslick');
    if (!empty($library)) {
      $form['poms_lang_display']['ddslick']['ddslick_height'] = [
        '#type' => 'number',
        '#title' => $this->t('Height'),
        '#description' => $this->t('Height in px for the drop down options i.e. 300. The scroller will automatically be added if options overflows the height. Use 0 for full height.'),
        '#size' => 8,
        '#maxlength' => 3,
        '#field_suffix' => 'px',
        '#default_value' => $this->configuration['ddslick']['ddslick_height'],
      ];

      if ($this->moduleHandler->moduleExists('languageicons')) {
        $form['poms_lang_display']['ddslick']['showSelectedHTML'] = [
          '#type' => 'checkbox',
          '#title' => $this->t('Show Flag'),
          '#default_value' => $this->configuration['ddslick']['showSelectedHTML'],
        ];

        $form['poms_lang_display']['ddslick']['imagePosition'] = [
          '#type' => 'select',
          '#title' => $this->t('Flag Position'),
          '#options' => [
            PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK_LEFT => $this->t('left'),
            PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK_RIGHT => $this->t('right'),
          ],
          '#default_value' => $this->configuration['ddslick']['imagePosition'],
          '#states' => [
            'visible' => [
              ':input[name="settings[poms_lang_display][ddslick][showSelectedHTML]"]' => ['checked' => TRUE],
            ],
          ],
        ];
      }
      else {
        $form['poms_lang_display']['ddslick']['showSelectedHTML'] = [
          '#type' => 'hidden',
          '#value' => $this->configuration['ddslick']['showSelectedHTML'],
        ];
        $form['poms_lang_display']['ddslick']['imagePosition'] = [
          '#type' => 'hidden',
          '#value' => $this->configuration['ddslick']['imagePosition'],
        ];
      }

      $ddsSkinOptions = [];
      foreach (_poms_lang_display_get_ddslick_skins() as $key => $value) {
        $ddsSkinOptions[$key] = $value['text'];
      }
      $form['poms_lang_display']['ddslick']['skin'] = [
        '#type' => 'select',
        '#title' => $this->t('Skin'),
        '#options' => $ddsSkinOptions,
        '#default_value' => $this->configuration['ddslick']['skin'],
      ];

      $form['poms_lang_display']['ddslick']['custom_skin'] = [
        '#type' => 'textfield',
        '#title' => $this->t('Custom skin name'),
        '#size' => 80,
        '#maxlength' => 55,
        '#default_value' => $this->configuration['ddslick']['custom_skin'],
        '#states' => [
          'visible' => [
            ':input[name="settings[poms_lang_display][ddslick][skin]"]' => ['value' => 'custom'],
          ],
        ],
      ];

    }
    else {
      $form['poms_lang_display']['ddslick']['ddslick_height'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['ddslick']['ddslick_height'],
      ];
      $form['poms_lang_display']['ddslick']['showSelectedHTML'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['ddslick']['showSelectedHTML'],
      ];
      $form['poms_lang_display']['ddslick']['imagePosition'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['ddslick']['imagePosition'],
      ];
      $form['poms_lang_display']['ddslick']['skin'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['ddslick']['skin'],
      ];
      $form['poms_lang_display']['ddslick']['custom_skin'] = [
        '#type' => 'hidden',
        '#value' => $this->configuration['ddslick']['custom_skin'],
      ];
    }

    // Configuration options that allow to hide a specific language
    // to specific roles.
    $form['poms_lang_display']['hideout'] = [
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this->t('Hide language settings'),
      '#description' => $this->t('Select which languages you want to hide to specific roles.'),
      '#weight' => 4,
    ];

    $languages = $this->languageManager->getLanguages();
    $roles = Role::loadMultiple();

    $role_names = [];
    $role_languages = [];
    foreach ($roles as $rid => $role) {
      // Retrieve role names for columns.
      $role_names[$rid] = new FormattableMarkup($role->label(), []);
      // Fetch languages for the roles.
      $role_languages[$rid] = !empty($this->configuration['hidden_languages'][$rid]) ? $this->configuration['hidden_languages'][$rid] : [];
    }

    // Store $role_names for use when saving the data.
    $form['poms_lang_display']['hideout']['role_names'] = [
      '#type' => 'value',
      '#value' => $role_names,
    ];

    $form['poms_lang_display']['hideout']['languages'] = [
      '#type' => 'table',
      '#header' => [$this->t('Languages')],
      '#id' => 'hidden_languages_table',
      '#sticky' => TRUE,
    ];

    foreach ($role_names as $name) {
      $form['poms_lang_display']['hideout']['languages']['#header'][] = [
        'data' => $name,
        'class' => ['checkbox'],
      ];
    }

    foreach ($languages as $code => $language) {
      $form['poms_lang_display']['hideout']['languages'][$code]['language'] = [
        '#type' => 'item',
        '#markup' => $language->getName(),
      ];

      foreach ($role_names as $rid => $role) {
        $form['poms_lang_display']['hideout']['languages'][$code][$rid] = [
          '#title' => $rid . ': ' . $language->getName(),
          '#title_display' => 'invisible',
          '#wrapper_attributes' => [
            'class' => ['checkbox'],
          ],
          '#type' => 'checkbox',
          '#default_value' => in_array($code, $role_languages[$rid], FALSE) ? 1 : 0,
          '#attributes' => ['class' => ['rid-' . $rid]],
        ];
      }
    }

    return $form;
  }

  /**
   * {@inheritdoc}
   */
  public function blockValidate($form, FormStateInterface $form_state) {
    $widget = $form_state->getValue('poms_lang_display')['widget'];
    switch ($widget) {
      case PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN:
        $library = $this->getLibraryByName('poms_lang_display', 'ms-dropdown');
        if (empty($library) || (isset($library['js']) && !file_exists($library['js'][0]['data']))) {
          $form_state->setErrorByName('settings', $this->t('You can\'t use <a href=":link">Marghoob Suleman Dropdown</a> output. You don\'t have the library installed.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN_URL]));
        }
        break;

      case PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN:
        $library = $this->getLibraryByName('poms_lang_display', 'chosen');
        if (empty($library) || (isset($library['js']) && !file_exists($library['js'][0]['data']))) {
          $form_state->setErrorByName('settings', $this->t('You can\'t use <a href=":link">Chosen</a> output. You don\'t have the library installed.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN_MOD_URL]));
        }
        break;

      case PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK:
        $library = $this->getLibraryByName('poms_lang_display', 'ddslick');
        if (empty($library) || (isset($library['js']) && !file_exists($library['js'][0]['data']))) {
          $form_state->setErrorByName('settings', $this->t('You can\'t use <a href=":link">ddSlick</a> output. You don\'t have the library installed.', [':link' => PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK_WEB_URL]));
        }
        break;

      default:
        break;
    }
  }

  /**
   * {@inheritdoc}
   */
  public function blockSubmit($form, FormStateInterface $form_state) {
    /** @var array[][] $poms_lang_display */
    $poms_lang_display = $form_state->getValue('poms_lang_display');
    $this->configuration['showall'] = $poms_lang_display['showall'];
    $this->configuration['hide_only_one'] = $poms_lang_display['hide_only_one'];
    $this->configuration['tohome'] = $poms_lang_display['tohome'];
    $this->configuration['width'] = $poms_lang_display['width'];
    $this->configuration['display'] = $poms_lang_display['display'];
    $this->configuration['widget'] = $poms_lang_display['widget'];
    $this->configuration['msdropdown'] = [
      'visible_rows' => $poms_lang_display['msdropdown']['visible_rows'],
      'rounded' => $poms_lang_display['msdropdown']['rounded'],
      'animation' => $poms_lang_display['msdropdown']['animation'],
      'event' => $poms_lang_display['msdropdown']['event'],
      'skin' => $poms_lang_display['msdropdown']['skin'],
      'custom_skin' => $poms_lang_display['msdropdown']['custom_skin'],
    ];
    $this->configuration['chosen'] = [
      'disable_search' => $poms_lang_display['chosen']['disable_search'],
      'no_results_text' => $poms_lang_display['chosen']['no_results_text'],
    ];
    $this->configuration['ddslick'] = [
      'ddslick_height' => $poms_lang_display['ddslick']['ddslick_height'],
      'showSelectedHTML' => $poms_lang_display['ddslick']['showSelectedHTML'],
      'imagePosition' => $poms_lang_display['ddslick']['imagePosition'],
      'skin' => $poms_lang_display['ddslick']['skin'],
      'custom_skin' => $poms_lang_display['ddslick']['custom_skin'],
    ];
    $this->configuration['languageicons'] = [
      'flag_position' => $poms_lang_display['languageicons']['flag_position'],
    ];

    $this->configuration['hidden_languages'] = [];
    /** @var string $code */
    /** @var array $values */

    if (isset($poms_lang_display['hideout']['languages']) && is_array($poms_lang_display['hideout']['languages'])) {
      foreach ($poms_lang_display['hideout']['languages'] as $code => $values) {
        unset($values['language']);
        foreach ($values as $rid => $value) {
          if ($value) {
            $this->configuration['hidden_languages'][$rid][] = $code;
          }
        }
      }
    }

  }

  /**
   * {@inheritdoc}
   */
  public function build() {
    $library = [];
    switch ($this->configuration['widget']) {
      case PomsLangDisplayConstants::LANGDROPDOWN_MSDROPDOWN:
        $library = $this->getLibraryByName('poms_lang_display', 'ms-dropdown');
        break;

      case PomsLangDisplayConstants::LANGDROPDOWN_CHOSEN:
        $library = $this->getLibraryByName('poms_lang_display', 'chosen');
        break;

      case PomsLangDisplayConstants::LANGDROPDOWN_DDSLICK:
        $library = $this->getLibraryByName('poms_lang_display', 'ddslick');
        break;
    }

    if (empty($library) && ($this->configuration['widget'] != PomsLangDisplayConstants::LANGDROPDOWN_SIMPLE_SELECT)) {
      return [];
    }

    $type = $this->getDerivativeId();
    $languages = $this->languageManager->getLanguageSwitchLinks($type, Url::fromRouteMatch(\Drupal::routeMatch()));

    if (isset($languages) && isset($languages->links) && is_array($languages->links)) {
      $roles = $this->currentUser->getRoles();

      list($entities, $accessible_translations) = $this->getEntitiesAndTranslations();
      foreach (array_keys($languages->links) as $langcode) {
        $hide_language = TRUE;

        foreach ($roles as $role) {
          if (!isset($this->configuration['hidden_languages'][$role]) || !in_array($langcode, $this->configuration['hidden_languages'][$role], FALSE)) {
            $hide_language = FALSE;
            break;
          }
        }

        if ($entities && !$this->configuration['showall'] && !in_array($langcode, $accessible_translations)) {
          $hide_language = TRUE;
        }

        // Remove the language if it should be hidden.
        if ($hide_language) {
          unset($languages->links[$langcode]);
        }
        else {
          $languages->links[$langcode]['language'] = $this->languageManager->getLanguage($langcode);
        }
      }
    }

    if (empty($languages->links)) {
      return [];
    }

    // Return an empty render array if accessible translations
    // or language links are one or zero.
    if (
      $this->configuration['hide_only_one'] &&
      (count($accessible_translations) === 1 || count($languages->links) === 1)
    ) {
      return [];
    }

    $form = $this->formBuilder->getForm(PomsLangDisplayForm::class, $languages->links, $type, $this->configuration);

    return [
      'poms_lang_display_form' => $form,
    ];
  }

  /**
   * {@inheritdoc}
   */
  public function getCacheContexts() {
    $contexts = parent::getCacheContexts();

    // Add all necessary cache contexts for proper language switching
    $contexts = Cache::mergeContexts($contexts, [
      'languages:' . $this->getDerivativeId(),
      'user.roles',
      'url.path',
      'url.query_args',
    ]);

    if ($this->configuration['hide_only_one']) {
      $contexts = Cache::mergeContexts($contexts, ['route']);
    }

    return $contexts;
  }

  /**
   * {@inheritdoc}
   */
  public function getCacheTags() {
    // Always include language config tag for language list changes.
    $tags = Cache::mergeTags(parent::getCacheTags(), [
      'config:configurable_language_list',
    ]);

    if (!$this->configuration['showall'] || $this->configuration['hide_only_one']) {
      list($entities,) = $this->getEntitiesAndTranslations();
      foreach ($entities as $entity) {
        $tags = Cache::mergeTags($tags, $entity->getCacheTags());
      }
    }

    return $tags;
  }


  /**
   * Get current route's translatable entities and accessible translations.
   */
  private function getEntitiesAndTranslations() {
    $entities = [];
    $accessible_translations = [];
    if (!$this->configuration['showall']) {
      foreach (\Drupal::routeMatch()->getParameters() as $param) {
        if ($param instanceof TranslationStatusInterface) {
          $entities[] = $param;
          $entity = $param;
          $accessible_translations = array_merge(
            $accessible_translations,
            array_filter(array_keys($entity->getTranslationLanguages()), function ($langcode) use ($entity) {
              $translation = method_exists($entity, 'getTranslation') ? $entity->getTranslation($langcode) : FALSE;
              return $translation && method_exists($translation, 'access') && $translation->access('view');
            })
          );
        }
      }
    }

    return [$entities, $accessible_translations];
  }

}
