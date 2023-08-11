const app=require('express')();

app.get('/',(req,res)=>{
    res.send('Hello World');
})

app.post('/',(req,res)=>{
    res.send('post on /');
})



app.get('/about/:age/*/*',(req,res)=>{
    console.log(req.params);
    res.send('About Page 2 '+req.params.age+' '+req.params[0]);
});

app.get('/parent/*', (req, res) => {
    console.log(req.params);
    res.send(`params: ${req.params}`);
  });
  

app.listen(4000,()=>{
    console.log('Server is running at port 4000');
});