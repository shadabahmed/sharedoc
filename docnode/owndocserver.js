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

var rooms = {};
io.sockets.on('connection', function (socket) {
  socket.on('join', function(data){
    socket.moderator = data.moderator;
    socket.roomid = data.documentid;
    if(socket.moderator){
      if(!rooms[socket.roomid])
        rooms[socket.roomid] = {document : {}, users : {list : {}}};
      rooms[socket.roomid].document.currentslide = data.currentslide;
      rooms[socket.roomid].users.moderator = data.userid;
    }
    rooms[socket.roomid].users.list[data.userid] = data.username;
    socket.join(socket.roomid);
    
    rooms[socket.roomid].ismoderator = rooms[socket.roomid].users.moderator == data.userid;
    / * Confirm Joined */
    socket.emit('joined', rooms[socket.roomid]);
    
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
      if(socket.moderator)
        socket.broadcast.to(socket.roomid).emit('moderatorleft');
      socket.leave(socket.roomid);
    }); 	
  });
});