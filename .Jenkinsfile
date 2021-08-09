properties([pipelineTriggers([githubPush()])])
node('master-local'){
  def namespace = 'pharmacy'
  def imageName = 'pmc-infra-krakend-ce'
  def releaseName = 'pmc-infra-krakend-ce'
  def chartName = 'general-application'
  def repository = 'https://github.com/Pharmacity-JSC/pmc-infra-krakend-ce'
  def environment
  def myRepo
  def gitBranchName
  def shortGitCommit 
  def dockerImageTag
  def dockerImageTagLatest
  def eksClusterDefault
  def awsAccessKeyID 
  def awsSecretKeyID
  def awsAccount
  stage('Checkout') {
    myRepo = checkout scm
    gitBranchName = myRepo.GIT_BRANCH
    // gitBranchName2 = scm.branches[0].name.split("/")[1]
    gitBranchName = gitBranchName.substring(gitBranchName.lastIndexOf('/')+1, gitBranchName.length())
    shortGitCommit = "${myRepo.GIT_COMMIT[0..10]}"
    if(gitBranchName == 'master' || gitBranchName == 'main' || gitBranchName == 'production')
    {
      echo "Working on branch ${gitBranchName}...!"
      environment = 'production'
      eksClusterDefault = 'prod-eks-main'
      awsAccount = 'aws_account_prod'
      dockerImageTag = "${environment}.${shortGitCommit}"
      dockerImageTagLatest = "${environment}.latest"
      withCredentials([aws(credentialsId: 'aws_account_prod', accessKeyVariable: 'aws_access_key_id', secretKeyVariable: 'aws_secret_access_key')]) {
        awsAccessKeyID = "${aws_access_key_id}"
        awsSecretKeyID = "${aws_secret_access_key}"
      }
    }  
    else if(gitBranchName == 'staging' || gitBranchName == 'stag' || gitBranchName == 'stg')
    {
      echo "Working on branch ${gitBranchName}...!"
      environment = 'staging'
      eksClusterDefault = 'stg-eks-main'
      awsAccount = 'aws_account_stag'
      dockerImageTag = "${environment}.${shortGitCommit}"
      dockerImageTagLatest = "${environment}.latest"
      withCredentials([aws(credentialsId: 'aws_account_stag', accessKeyVariable: 'aws_access_key_id', secretKeyVariable: 'aws_secret_access_key')]) {
        awsAccessKeyID = "${aws_access_key_id}"
        awsSecretKeyID = "${aws_secret_access_key}"
      }
    }
    else
    {
      echo "Working on branch ${gitBranchName}...!"
      environment = 'development'
      namespace = 'pmc-testing'
      eksClusterDefault = 'stg-eks-main'
      awsAccount = 'aws_account_stag'
      dockerImageTag = "${environment}.${shortGitCommit}"
      dockerImageTagLatest = "${environment}.latest"
      withCredentials([aws(credentialsId: 'aws_account_stag', accessKeyVariable: 'aws_access_key_id', secretKeyVariable: 'aws_secret_access_key')]) {
        awsAccessKeyID = "${aws_access_key_id}"
        awsSecretKeyID = "${aws_secret_access_key}"
      }
    }
  }

  stage("Slack") {
    slackSend(
      color: "good", 
      message: "Project ${repository} is building...!\nOn branch ${gitBranchName}"
    )
  }

  stage("Build krakend"){
    println('Building krakend with golang')
    sh '[ -f krakend ] && rm krakend || echo "File does not exist !"'
    sh 'make build'
  }

  stage('Build docker') {
    withCredentials([string(credentialsId: 'aws_ecr_account_url', variable: 'ecr_url'), string(credentialsId: 'aws_default_region', variable: 'aws_region')]) {
      withEnv(["AWS_DEFAULT_REGION=${aws_region}",
        "AWS_ACCESS_KEY_ID=${awsAccessKeyID}",
        "AWS_SECRET_ACCESS_KEY=${awsSecretKeyID}"]){
        sh "set +x; aws ecr describe-repositories --repository-names ${imageName} 2>&1 > /dev/null || aws ecr create-repository --repository-name ${imageName} --image-scanning-configuration scanOnPush=true"
        docker.withRegistry("https://${ecr_url}", "ecr:${aws_region}:${awsAccount}") {
          def dockerImage = docker.build("${imageName}:${dockerImageTag}","-t ${imageName}:${dockerImageTagLatest} .")
          dockerImage.push()
          dockerImage.push("${dockerImageTagLatest}")
        }
        echo "[SUCCESS] Push image ${imageName}:${dockerImageTag} and ${imageName}:${dockerImageTagLatest} to ECR"  
      }
    }
  }
}
