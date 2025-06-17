pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'herianto9671/assessment-app:latest'
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
    }

    tools {
        maven 'Maven-3.8'
        jdk 'OpenJDK-24'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Build & Compile') {
            steps {
                echo 'Building application...'
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    // Skip coverage karena tidak ada jacoco plugin
                }
            }
        }

        stage('Code Quality Analysis') {
            parallel {
                stage('SonarQube Scan') {
                    steps {
                        echo 'Running SonarQube analysis...'
                        withSonarQubeEnv('SonarQube') {
                            sh 'mvn sonar:sonar'
                        }
                    }
                }

                stage('Security Scan') {
                    steps {
                        echo 'Running security scan...'
                        sh 'mvn org.owasp:dependency-check-maven:check'
                    }
                }
            }
        }

        stage('Package Application') {
            steps {
                echo 'Packaging application...'
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/assessment-*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", env.DOCKER_CREDENTIALS) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Development') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to Development environment...'
                script {
                    sh """
                        sed -i 's|IMAGE_TAG|${DOCKER_TAG}|g' k8s/deployment.yaml
                        kubectl apply -f k8s/ -n development
                        kubectl rollout status deployment/assessment-app -n development
                    """
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                echo 'Deploying to Staging environment...'
                script {
                    sh """
                        sed -i 's|IMAGE_TAG|${DOCKER_TAG}|g' k8s/deployment.yaml
                        kubectl apply -f k8s/ -n staging
                        kubectl rollout status deployment/assessment-app -n staging
                    """
                }
            }
            post {
                success {
                    echo 'Running integration tests...'
                    sh 'mvn verify -Dspring.profiles.active=staging'
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                echo 'Deploying to Production environment...'
                script {
                    sh """
                        sed -i 's|IMAGE_TAG|${DOCKER_TAG}|g' k8s/deployment.yaml
                        kubectl apply -f k8s/ -n production
                        kubectl rollout status deployment/assessment-app -n production
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    def namespace = 'development'
                    if (env.BRANCH_NAME == 'staging') {
                        namespace = 'staging'
                    } else if (env.BRANCH_NAME == 'main') {
                        namespace = 'production'
                    }

                    sh """
                        sleep 30
                        kubectl get pods -n ${namespace}
                        kubectl logs -l app=assessment-app -n ${namespace} --tail=50
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }

        success {
            echo 'Pipeline completed successfully!'
            emailext (
                subject: "BUILD SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>BUILD SUCCESS</p>
                        <p>Job: ${env.JOB_NAME}</p>
                        <p>Build Number: ${env.BUILD_NUMBER}</p>
                        <p>Git Commit: ${env.GIT_COMMIT_SHORT}</p>""",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }

        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "BUILD FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>BUILD FAILED</p>
                        <p>Job: ${env.JOB_NAME}</p>
                        <p>Build Number: ${env.BUILD_NUMBER}</p>
                        <p>Git Commit: ${env.GIT_COMMIT_SHORT}</p>
                        <p>Check console output at: ${env.BUILD_URL}</p>""",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}