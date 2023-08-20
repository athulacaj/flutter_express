const app=require('express')();



app.get("/",(req,res)=>{
    res.send({message:"Hello World"});
});

app.get("/json",(req,res)=>{
    res.json({"msg": "hello"});
});

app.listen(4000,()=>{
    console.log('Server is running at port 4000');
});