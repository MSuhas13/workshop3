pipeline {

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'awsService', choices: ['EC2', 'S3'], description: 'Select AWS Service to Create')
		choice(name: 'action', choices: ['create', 'destroy'], description: 'AWS Service to Create or destroy')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                     def repoUrl = ''
                     def subDirectory = ''
                    if (params.awsService == 'EC2') {
                        repoUrl = "https://github.com/velayutham19931208/TF_AutoJen_Inst.git"
                        subDirectory = 'ec2'
                    } else if (params.awsService == 'S3') {
                               repoUrl =  "https://github.com/velayutham19931208/S3-TF-repo.git"
                               subDirectory = 's3' 
                    } else {
                                error("Invalid AWS service selection")
                            }
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'YOUR_CREDENTIALS_ID', url: repoUrl]]])
                     dir(subDirectory) {
                        }
                    }
                }
            }

        stage('Plan') {
            steps {
                sh "terraform init"
                sh "terraform plan -out tfplan"
                sh "terraform show -no-color tfplan > tfplan.txt"
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }

           steps {
               script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            steps {
                script {
                    def terraformAction = params.action
                    echo "terraform action is --> ${terraformAction}"

                     if (terraformAction == 'create') {
                         sh "terraform apply -input=false tfplan"
                     } else if (terraformAction == 'destroy') {
                         sh "terraform destroy -input=false -auto-approve"
                     } else {
                         error("Invalid action selected: ${terraformAction}")
                      }
                  }
             }
         }
    }

  }
