pipeline {
    agent any

    environment {
        DOCKER_USER = 'avipon23in'
        APP_HOST = '10.0.2.205'
        DB_HOST = '10.0.2.149'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                docker build \
                  -t ${DOCKER_USER}/blog-frontend:${BUILD_NUMBER} \
                  -t ${DOCKER_USER}/blog-frontend:latest \
                  app/frontend
                '''
            }
        }

        stage('Build Backend') {
            steps {
                sh '''
                docker build \
                  -t ${DOCKER_USER}/blog-backend:${BUILD_NUMBER} \
                  -t ${DOCKER_USER}/blog-backend:latest \
                  app/backend
                '''
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    )
                ]) {
                    sh '''
                    echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin

                    docker push ${DOCKER_USER}/blog-frontend:${BUILD_NUMBER}
                    docker push ${DOCKER_USER}/blog-frontend:latest

                    docker push ${DOCKER_USER}/blog-backend:${BUILD_NUMBER}
                    docker push ${DOCKER_USER}/blog-backend:latest

                    docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['blogging-deploy-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no \
                        ubuntu@${APP_HOST} \
                        "docker pull ${DOCKER_USER}/blog-frontend:latest && \
                         docker pull ${DOCKER_USER}/blog-backend:latest"
                    '''
                }
            }
        }
    }
}
