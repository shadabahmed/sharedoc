var app = require('http').createServer(handler)
, io = require('socket.io').listen(app);

app.listen(1337);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
    function (err, data) {
      if (err) {
        res.writeHead(500);
        return res.end('Error loading index.html');
      }

      res.writeHead(200);
      res.end(data);
    });
}

var conferences = {};
io.sockets.on('connection', function (socket) {
  socket.on('conf_join', function(data){
    try{
        var confid = data.doc.id + ':' + data.confid;
        socket.confid = confid;
        data.user.host = data.confid == data.user.id;
        socket.user = data.user;
        if(socket.user.host){
          if(!conferences[socket.confid])
              conferences[socket.confid] = {doc : data.doc, users : {list : {}, host: data.user.id, moderators : []}};
           conferences[socket.confid].users.moderators.push(data.user.id);
        }
        conferences[socket.confid].users.list[data.user.id] = data.user.name;
        socket.join(socket.confid);

        / * Confirm Joined */
        socket.emit('conf_joined', conferences[socket.confid]);
        /* Broadcast to everyone joined */
        socket.broadcast.to(socket.confid).emit('conf_new_user', {users : conferences[socket.confid].users, user : socket.user})

    }
    catch(err){console.log(err)}
    /* Slide Change Callback */
    socket.on('slidechange',function(data){
      rooms[socket.roomid].document.currentslide = data.currentslide;
      socket.broadcast.to(socket.roomid).emit('slidechanged', rooms[socket.roomid].document.currentslide);
    });
    
    /* Chat recieved callback */
    socket.on('chatsent',function(data){
      socket.broadcast.to(socket.roomid).emit('chatreceived', documents[socket.roomid]);
    });
    
    /* disconnect recieved */
    socket.on('disconnect', function(){
      var users = {};
      if(socket.user.host)
        delete conferences[socket.confid];
       else{
        delete conferences[socket.confid].users.list[socket.user.id];
        userIndex = conferences[socket.confid].users.moderators.indexOf(socket.user.id)
        delete conferences[socket.confid].users.moderators[userIndex]
        users = conferences[socket.confid].users;
      }
      socket.broadcast.to(socket.confid).emit('conf_user_left', {users : users, user : socket.user});
      socket.leave(socket.confid);
    }); 	
  });
});