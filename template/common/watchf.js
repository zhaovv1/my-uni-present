var watch = require('watch')
const filePath = './src'
console.log(`正在监听 ${filePath}`);
var exec = require('child_process').exec; 
watch.watchTree(filePath, function (f, curr, prev) {
    if (typeof f == "object" && prev === null && curr === null) {
      // Finished walking the tree
        console.log("--Finished walking the tree---");
    } else if (prev === null) {
      // f is a new file
        console.log("开始编译...");
        exec('sh ./rebuildandroid.sh', function(err,stdout,stderr){
            if(err) {
                console.log('编译 error:'+stderr);
            } else {
                console.log('编译完成');
            }
        })
    } else if (curr.nlink === 0) {
      // f was removed
        console.log("开始编译...");
        exec('sh ./rebuildandroid.sh', function(err,stdout,stderr){
            if(err) {
                console.log('编译 error:'+stderr);
            } else {
                console.log('编译完成');
            }
        })
    } else {
      // f was changed
        console.log("开始编译...");
        exec('sh ./rebuildandroid.sh', function(err,stdout,stderr){
            if(err) {
                console.log('编译 error:'+stderr);
            } else {
                console.log('编译完成');
            }
        })
    }
})