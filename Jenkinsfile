pipeline {
  environment {
    registry = 'registry-intl.ap-southeast-1.aliyuncs.com/swmeng/wmdraw-'
    registryCredential = 'aliclouddocker'
    DOCKER_CREDENTIALS = credentials('aliclouddocker')
    SERVER_IP = credentials('ALICLOUD_ECS_HK_IP')
  }
  agent any
  stages {
    stage('Build Images') {
      steps {
        script {
          clientImage = docker.build(registry + 'client', './')
        }
      }
    }
    stage('Push Images') {
      steps {
        script {
          docker.withRegistry('https://registry-intl.ap-southeast-1.aliyuncs.com', registryCredential ) {
            clientImage.push("${env.BUILD_NUMBER}")
            clientImage.push('latest')
          }
        }
      }
    }
    stage('Remove Unused Docker Image') {
      steps {
        sh "docker rmi ${registry}client"
      }
    }
    stage('Deploy Images') {
      steps {
        sshagent(credentials:['alicloudchkl']) {
            sh "scp -o StrictHostKeyChecking=no -r ./deploy root@$SERVER_IP:/root"
            sh "ssh -o StrictHostKeyChecking=no root@47.254.193.66 \"export BUILD_NUMBER=${env.BUILD_NUMBER} && docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW registry-intl.ap-southeast-1.aliyuncs.com && cd deploy && sh ./deploy.sh\""
          }
      }
    }
  }
}