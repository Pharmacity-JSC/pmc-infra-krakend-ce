// Author: Dang Thanh Phat
// Email: thanhphatit95@gmail.com
// Blog: itblognote.com
// Description: Code pipeline for Jenkins to deploy krakend ce
// ============================START============================
@Library(value='jenkinsfile-lib', changelog=false) _
properties([pipelineTriggers([githubPush()])])
def sendTo = 'phat.dangthanh@pharmacity.vn'
node('master-local') {
  try {
    def gitRepoName = 'pmc-infra-krakend-ce'
    // notifyBuild('STARTED', "${sendTo}")
    jenkinsKrakendCE("${gitRepoName}")
  } catch (e) {
    // Only failure send notifications
    currentBuild.result = "FAILED"
    notifyBuild("${currentBuild.result}", "${sendTo}")
    throw e
  } finally {
    println("Build status: ${currentBuild.result}")
    // Success or failure, always send notifications
    // notifyBuild(currentBuild.result)
  }
}