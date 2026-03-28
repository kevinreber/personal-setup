import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header
      style={{
        padding: '4rem 0',
        textAlign: 'center',
        position: 'relative',
        overflow: 'hidden',
      }}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div style={{display: 'flex', gap: '1rem', justifyContent: 'center', marginTop: '1.5rem'}}>
          <Link
            className="button button--primary button--lg"
            to="/docs/getting-started">
            Get Started
          </Link>
          <Link
            className="button button--secondary button--lg"
            href="https://github.com/kevinreber/personal-setup">
            View on GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}

function Features() {
  const features = [
    {
      title: 'One Command Setup',
      description:
        'Bootstrap a fresh Mac with a single curl command. Installs Homebrew, apps, shell configs, SSH keys, and more.',
    },
    {
      title: 'Automated Backups',
      description:
        'Shell configs are automatically backed up every 6 hours via launchd. Never lose your dotfiles again.',
    },
    {
      title: 'Work/Personal Separation',
      description:
        'Git automatically uses different SSH keys and emails based on your project directory. No manual switching needed.',
    },
  ];

  return (
    <section style={{padding: '2rem 0'}}>
      <div className="container">
        <div className="row">
          {features.map(({title, description}) => (
            <div key={title} className="col col--4" style={{marginBottom: '2rem'}}>
              <div style={{padding: '0 1rem'}}>
                <Heading as="h3">{title}</Heading>
                <p>{description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title="Home"
      description={siteConfig.tagline}>
      <HomepageHeader />
      <main>
        <Features />
      </main>
    </Layout>
  );
}
