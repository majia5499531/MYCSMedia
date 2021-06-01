
//构造方法
const DataManager = function()
{
      this.userId = '123123123123';
      this.mobile = '13080562779';
      this.ipAddress = '127.0.0.1';
      this.appVer = '4.3.9';
      this.env = 'dev';
      this.upload = function(){
            console.log('uploading...'+this.appVer);
      };

      this.xxx = ()=>{console.log(this.ipAddress)};
};


//构造方法
const News = function()
{
      this.contentForm = "news";
      this.newsTItle = 'President Election';
      this.author = 'zhcs';
      this.desc = 'donnald trump faild at the Election of America President';
      this.text = 'okokokokokokokokookok ijijijijij plplplplpl qweqwqeqwqw, asdasdasdasc,xzczxcxzczxc,vcbvcbvcbvcb.';
}


//构造方法
const Content = function()
{
      this.contentId = '23$!!!%!@$#^#^&&&@';
      this.contentDate = '2020.1.1';
      this.reads = '222200021';
}




new Promise(function (resolve, reject) {

      console.log('begin');
      resolve('999');

  }).then(function (suc) {

      console.log(suc);

      return 'sss';

  }).then(function(data){
      console.log(data);

      return "oll";
  }).then(function(data){

      console.log(data);

  })
  
  .catch(function (err) {
      console.log('错误捕捉'+err);

  }).finally(function (data) {
      console.log("Promise结束");

  });






//输出对象
function mjlog(obj){
	var output = "";
	for(var i in obj){
		var property=obj[i];
		output+=i+" = "+property+"\n";
	}
	console.log(output);
};


//输出名字
function printName(a,b){

      console.log(this.userId);
      console.log(a+b);

}