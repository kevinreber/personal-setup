// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    'getting-started',
    {
      type: 'category',
      label: 'Guides',
      items: [
        'guides/github-ssh-setup',
        'guides/github-ssh-quick-start',
        'guides/shell-config-backup',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      items: [
        'reference/project-structure',
        'reference/setup-script',
      ],
    },
  ],
};

export default sidebars;
