pipeline {
    agent {
        label "some_agent"
    }
    environment {
      CLUSTER1_MASTER_IP = ""
      CLUSTER2_MASTER_IP = ""
      CLUSTER3_MASTER_IP = ""
      SSH_KEY = "SSH_KEY_PATH"
    }
    parameters {
      choice(name: 'CLUSTER', choices: ['Cluster1', 'Cluster2' , 'Cluster3'], description: 'Choose cluster to implement RBAC')  
      choice(name: 'ROLE', choices: ['ClusterRole', 'Role'], description: 'Choose Role to deploy')
      string(name: 'NAMESPACE', defaultValue: '', description: 'Enter namespace if you want to create role for specific namespace')
      string(name: 'USERNAME', defaultValue: '', description: 'Enter username ex. firstname.lastname')
      string(name: 'EMAIL', defaultValue: '', description: 'Enter email of the user with @organization.com ex. firstname.lastname@organization.com')
      choice(name: 'ACTION', choices: ['plan', 'apply'], description: 'Choose Action')  
    }
    stages {
      stage('Decide Master Node') {
        steps {
          script {
            def MASTER_IP
                    if (params.CLUSTER == 'Cluster1') {
                        MASTER_IP = CLUSTER1_MASTER_IP
                    } else if (params.CLUSTER == 'Cluster2') {
                        MASTER_IP = CLUSTER2_MASTER_IP
                    } else if (params.CLUSTER == 'Cluster3') {
                        MASTER_IP = CLUSTER3_MASTER_IP
                    }
                    env.MASTER_IP = MASTER_IP
                    sh "echo MASTER_IP: ${MASTER_IP}"
          }
        }
      }
      stage('Copy KUBECONFIG from MasterNode') {
        steps {
          dir("${WORKSPACE}") {
          sh """
            scp -i ${SSH_KEY} root@${env.MASTER_IP}:/etc/rancher/rke2/rke2.yaml kubeconfig.yaml
            sed -i "s|https://127.0.0.1:6443|https://${env.MASTER_IP}:6443|g" kubeconfig.yaml
          """
          }
        }
      }
      stage('Deploy RBAC') {
        steps {
          dir("${WORKSPACE}") {
          sh """
            chmod a+x config.sh
            /bin/bash config.sh 
          """
          }
        }
      }
      stage('Extract Config'){
        steps{
          dir("${WORKSPACE}") {
            sh """
              chmod a+x generateconfig.sh
              /bin/bash generateconfig.sh
            """
          }
        }
      }
    }  
    post {
        always {
            script {
                emailext attachmentsPattern: "kubeconfig_user.yaml",
                    body: 'Download the kubeconfig file to connect to the cluster',
                    subject: 'Kubeconfig for Cluster connection',
                    to: "$EMAIL"
            }
        }
      aborted {
          echo 'Pipeline was aborted'
      }
      failure {
          mail to: "aniecesedhai@gmail.com",
          subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
          body: "Something is wrong with ${env.BUILD_URL}"
      }
    }
}
    

