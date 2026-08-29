cd ~/cloud-native-blogging-platform
cat > Jenkinsfile <<'EOF'
pipeline {
    agent any

    environment {
        DOCKER_USER = 'avipon23in'
        APP_HOST    = '10.0.2.205'
        DB_HOST     = '10.0.2.149'
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
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'blogging-deploy-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        ssh -i "$SSH_KEY" \
                          -o StrictHostKeyChecking=no \
                          "$SSH_USER@$APP_HOST" "
                            docker network create blog-network 2>/dev/null || true

                            docker pull ${DOCKER_USER}/blog-frontend:latest
                            docker pull ${DOCKER_USER}/blog-backend:latest

                            docker rm -f blog-frontend blog-backend 2>/dev/null || true

                            docker run -d \
                              --name blog-backend \
                              --network blog-network \
                              --network-alias backend \
                              -p 5000:5000 \
                              -e DB_HOST=${DB_HOST} \
                              -e DB_USER=bloguser \
                              -e DB_PASSWORD=blogpass \
                              -e DB_NAME=blogdb \
                              ${DOCKER_USER}/blog-backend:latest

                            docker run -d \
                              --name blog-frontend \
                              --network blog-network \
                              -p 80:80 \
                              ${DOCKER_USER}/blog-frontend:latest
                          "
                    '''
                }
            }
        }
    }
}
EOF
