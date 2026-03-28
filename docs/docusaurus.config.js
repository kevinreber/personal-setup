// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Personal Setup',
  tagline: 'Documentation for bootstrapping and maintaining a Mac development environment',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://kevinreber.github.io',
  baseUrl: '/personal-setup/',

  organizationName: 'kevinreber',
  projectName: 'personal-setup',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl:
            'https://github.com/kevinreber/personal-setup/tree/main/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'Personal Setup',
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docsSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/kevinreber/personal-setup',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Getting Started',
                to: '/docs/getting-started',
              },
              {
                label: 'GitHub & SSH Setup',
                to: '/docs/guides/github-ssh-setup',
              },
              {
                label: 'Shell Config Backup',
                to: '/docs/guides/shell-config-backup',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/kevinreber/personal-setup',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Kevin Reber. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash', 'ini'],
      },
    }),
};

export default config;
