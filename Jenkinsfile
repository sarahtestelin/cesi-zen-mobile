pipeline {
    agent {
        label 'mac-flutter'
    }

    stages {
        stage('Environment') {
            steps {
                sh 'flutter --version'
                sh 'java -version'
            }
        }

        stage('Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Analyze') {
            steps {
                sh 'flutter analyze'
            }
        }

        stage('Build APK') {
            steps {
                sh 'flutter build apk --debug'
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk',
                             fingerprint: true
            echo 'Pipeline CESIZen Mobile réussi.'
        }

        failure {
            echo 'Pipeline CESIZen Mobile en échec.'
        }
    }
}
