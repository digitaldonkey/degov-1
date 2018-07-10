def label = UUID.randomUUID().toString()

timestamps {

  podTemplate(serviceAccount: 'jenkins', label: label, containers: [
    containerTemplate(name: 'php', image: 'derh4nnes/pipeline-behat:latest', ttyEnabled: true, command: 'cat',
        resourceRequestCpu: '1',
        resourceLimitMemory: '1200Mi')
    ]) {

    node(label) {
      stage('Checkout') {
        checkout scm
      }
      stage('Build and Test') {
        container('php') {
          sh 'composer create-project degov/degov-project'
          sh 'cd degov-project'
          sh 'composer require degov/degov:dev-$BITBUCKET_BRANCH#$BITBUCKET_COMMIT'
          sh 'php -S localhost:80 -t docroot &'
          sh 'export PATH="$HOME/.composer/vendor/bin:$PATH"'
          sh 'phpstan analyse docroot/profiles/contrib/degov -c docroot/profiles/contrib/degov/phpstan.neon --level=1 || true'
          sh ''(cd docroot/profiles/contrib/degov && phpunit)''
          sh 'bin/drush si degov --db-url=sqlite://sites/default/files/db.sqlite -y'
          sh 'mv docroot/profiles/contrib/degov/behat.yml .'
          sh 'behat'
        }
      }
    }
  }

}
