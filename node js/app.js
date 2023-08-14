const app=require('express')();

function middleware(req,res,next){
    console.log('Middleware');
    res.send('Middleware');
    next();
    console.log('Middleware next');
}

app.use(middleware);

app.get('/',middleware,(req,res)=>{
    res.send('Hello World');
})

app.post('/',(req,res)=>{
    res.send('post on /');
})



app.get('/about/:name/*/*',(req,res)=>{
    console.log(req.params);
    res.send('About Page 2 '+req.params.name+' '+req.params);
});

app.get('/parent/*', (req, res) => {
    console.log(req.params);
    res.send(`params: ${req.params}`);
  });
  

app.use((re,res,next)=>{
    console.log('* middleware');
    next();
})

app.listen(4000,()=>{
    console.log('Server is running at port 4000');
});