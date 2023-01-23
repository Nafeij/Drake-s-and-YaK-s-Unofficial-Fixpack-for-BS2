package game.gui.page
{
   import engine.battle.fsm.BattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.pref.PrefEvent;
   import engine.gui.core.GuiSprite;
   import engine.session.Chat;
   import engine.session.ChatEvent;
   import engine.session.ChatMsg;
   import engine.session.ChatRoomEvent;
   import engine.session.ChatRoomMsg;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.GuiChatColor;
   import game.gui.GuiGamePrefs;
   import game.gui.IGuiChat;
   import game.gui.battle.IGuiBattleChatListener;
   import game.session.states.SceneState;
   
   public class GlobalChatHelper implements IGuiBattleChatListener
   {
      
      public static var mcClazz:Class;
       
      
      protected var chat:IGuiChat;
      
      public var chatroom:String;
      
      private var container:GamePage;
      
      private var config:GameConfig;
      
      private var _showWhenUnfocused:Boolean = true;
      
      private var _showChatButton:Boolean = true;
      
      private var _enabled:Boolean = true;
      
      private var theClazz:Class;
      
      public var align:String = "upperleft";
      
      public var _alignTopGlobal:Number = 0;
      
      private var alignTop:Number = 0;
      
      private var alignTopDirty:Boolean;
      
      public var _alignLeftGlobal:Number = 0;
      
      private var _alignLeft:Number = 0;
      
      private var alignLeftDirty:Boolean;
      
      public function GlobalChatHelper(param1:GamePage, param2:GameConfig, param3:String, param4:Class = null)
      {
         this.theClazz = mcClazz;
         super();
         this.chatroom = param3;
         this.config = param2;
         this.container = param1;
         if(param4)
         {
            this.theClazz = param4;
         }
         param2.fsm.chat.addEventListener(ChatEvent.TYPE,this.chatEventHandler);
         param2.fsm.chat.addEventListener(ChatRoomEvent.TYPE,this.chatRoomEventHandler);
         param2.globalPrefs.addEventListener(PrefEvent.PREF_CHANGED,this.prefChangedHandler);
         this.prefChangedHandler(null);
         this.checkChatInit();
      }
      
      private function prefChangedHandler(param1:PrefEvent) : void
      {
         if(this.chat)
         {
            this.chat.chatVisible = this.config.globalPrefs.getPref(GuiGamePrefs.PREF_OPTION_CHAT);
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      private function setEnabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(this.chat)
         {
            this.chat.movieClip.visible = this._enabled;
            this.chat.setEnabledAvailable(this.enabled);
         }
      }
      
      public function get alignLeft() : Number
      {
         return this._alignLeft;
      }
      
      public function set alignLeft(param1:Number) : void
      {
         this._alignLeft = param1;
         this.alignLeftDirty = false;
      }
      
      public function cleanup() : void
      {
         this.config.globalPrefs.removeEventListener(PrefEvent.PREF_CHANGED,this.prefChangedHandler);
         if(Boolean(this.chat) && Boolean(this.chat.movieClip.parent))
         {
            this.chat.movieClip.parent.removeChild(this.chat.movieClip);
         }
         this.config.fsm.chat.removeEventListener(ChatEvent.TYPE,this.chatEventHandler);
         this.config.fsm.chat.removeEventListener(ChatRoomEvent.TYPE,this.chatRoomEventHandler);
         this.config = null;
         this.container = null;
      }
      
      protected function handlePostChatInit() : void
      {
      }
      
      protected function checkChatInit() : void
      {
         var _loc1_:Object = null;
         if(this.chat)
         {
            return;
         }
         this.chat = new this.theClazz() as IGuiChat;
         this.chat.showWhenUnfocused = this._showWhenUnfocused;
         this.chat.showChatButton = this._showChatButton;
         this.container.addChild(this.chat.movieClip);
         this.chat.init(this.config.gameGuiContext,this);
         this.handlePostChatInit();
         this.chat.movieClip.y = 0;
         this.chat.movieClip.x = this.container.width / 2;
         this.config.keybinder.bind(false,false,false,Keyboard.ENTER,new Cmd("chat_enter",this.chatEnterFunc),KeyBindGroup.CHAT);
         this.config.fsm.chat.enterRoom(this.chatroom);
         this.chat.movieClip.visible = this._enabled;
         this.resize();
         for each(_loc1_ in this.config.fsm.chat.globalMsgs)
         {
            this.processMsg(_loc1_,false);
         }
      }
      
      public function set alignTopGlobal(param1:Number) : void
      {
         if(this._alignTopGlobal != param1)
         {
            this.alignTopDirty = true;
            this._alignTopGlobal = param1;
            this.resize();
         }
      }
      
      public function set alignLeftGlobal(param1:Number) : void
      {
         if(this._alignLeftGlobal != param1)
         {
            this.alignLeftDirty = true;
            this._alignLeftGlobal = param1;
            this.resize();
         }
      }
      
      private function checkAlignTopDirty() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         if(this.alignTopDirty && Boolean(this.chat.movieClip.parent))
         {
            _loc1_ = new Point(0,this._alignTopGlobal);
            _loc2_ = this.chat.movieClip.parent.globalToLocal(_loc1_);
            this.alignTop = _loc2_.y;
            this.alignTopDirty = false;
         }
      }
      
      private function checkAlignLeftDirty() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         if(this.alignLeftDirty && Boolean(this.chat.movieClip.parent))
         {
            _loc1_ = new Point(this._alignLeftGlobal,0);
            _loc2_ = this.chat.movieClip.parent.globalToLocal(_loc1_);
            this.alignLeft = _loc2_.x;
            this.alignLeftDirty = false;
         }
      }
      
      public function resize() : void
      {
         if(this.chat)
         {
            this.checkAlignTopDirty();
            this.checkAlignLeftDirty();
            if(this.align == "upperleft")
            {
               this.chat.movieClip.x = this.alignLeft;
               this.chat.movieClip.y = this.alignTop;
            }
            else if(this.align == "bottomcenter")
            {
               this.chat.movieClip.x = (this.container.width - this.chat.chatWidth) / 2;
               this.chat.movieClip.y = this.container.height - this.chat.movieClip.height;
            }
            else if(this.align == "topcenter")
            {
               this.chat.movieClip.x = (this.container.width - this.chat.chatWidth) / 2;
               this.chat.movieClip.y = this.alignTop;
            }
         }
      }
      
      public function makeChildOfPage(param1:GamePage) : void
      {
         if(this.chat.movieClip.parent != param1)
         {
            param1.addChild(this.chat.movieClip);
         }
         this.chat.setEnabledAvailable(true);
      }
      
      public function guiBattleChatTextEntered(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(param1)
         {
            _loc2_ = this.chatroom;
            if(param1.charAt(0) == "/")
            {
               _loc3_ = param1.indexOf(" ");
               if(_loc3_ > 0)
               {
                  _loc4_ = param1.substring(1,_loc3_);
                  if(_loc4_ == Chat.GLOBAL_ROOM.substr(0,_loc4_.length))
                  {
                     if(!this.config.factions)
                     {
                        return;
                     }
                     _loc2_ = Chat.GLOBAL_ROOM;
                     param1 = param1.substring(_loc3_ + 1,param1.length);
                  }
                  else if(_loc4_ == Chat.LOBBY_ROOM_PREFIX.substr(0,_loc4_.length))
                  {
                     if(!this.config.factions)
                     {
                        return;
                     }
                     _loc2_ = this.config.factions.lobbyManager.current.chatRoomId;
                     param1 = param1.substring(_loc3_ + 1,param1.length);
                  }
                  else if(_loc4_ == "shell")
                  {
                     param1 = param1.substring(_loc3_ + 1,param1.length);
                     this.config.shell.exec(param1);
                     this.chat.unfocusChat();
                     return;
                  }
               }
            }
            this.config.fsm.chat.sendMessage(_loc2_,param1);
         }
         this.chat.unfocusChat();
      }
      
      private function chatEventHandler(param1:ChatEvent) : void
      {
         this.processChatMsg(param1.msg,true);
      }
      
      private function chatRoomEventHandler(param1:ChatRoomEvent) : void
      {
         this.processChatRoomMsg(param1.msg);
      }
      
      private function processMsg(param1:Object, param2:Boolean) : void
      {
         if(param1 is ChatRoomMsg)
         {
            this.processChatRoomMsg(param1 as ChatRoomMsg);
         }
         else if(param1 is ChatMsg)
         {
            this.processChatMsg(param1 as ChatMsg,param2);
         }
      }
      
      private function processChatMsg(param1:ChatMsg, param2:Boolean) : void
      {
         var _loc7_:IBattleParty = null;
         var _loc8_:Boolean = false;
         if(this.chatroom != param1.room)
         {
            if(param1.room != Chat.GLOBAL_ROOM)
            {
               if(param1.room.indexOf(Chat.LOBBY_ROOM_PREFIX) != 0)
               {
                  return;
               }
            }
         }
         var _loc3_:GuiChatColor = null;
         var _loc4_:BattleFsm = null;
         var _loc5_:SceneState = this.config.fsm.current as SceneState;
         if(_loc5_)
         {
            _loc4_ = !!_loc5_.battleHandler ? _loc5_.battleHandler.fsm : null;
         }
         if(Chat.GLOBAL_ROOM == param1.room)
         {
            _loc3_ = GuiChatColor.GLOBAL;
         }
         else if(param1.room.indexOf(Chat.LOBBY_ROOM_PREFIX) == 0)
         {
            _loc3_ = GuiChatColor.LOBBY;
         }
         else if(Boolean(_loc4_) && _loc4_.battleId == param1.room)
         {
            _loc7_ = _loc4_.board.getPartyById(param1.user.toString());
            _loc8_ = Boolean(_loc7_) && _loc7_.isEnemy;
            _loc3_ = _loc8_ ? GuiChatColor.BATTLE_ENEMY : GuiChatColor.BATTLE_SELF;
         }
         var _loc6_:* = param1.username;
         if(this.chatroom != param1.room)
         {
            if(Chat.GLOBAL_ROOM == param1.room)
            {
               _loc6_ += " (global)";
            }
            else if(param1.room.indexOf(Chat.LOBBY_ROOM_PREFIX) == 0)
            {
               _loc6_ += " (lobby)";
            }
            else if(Boolean(_loc4_) && _loc4_.battleId == param1.room)
            {
               _loc6_ += " (battle)";
            }
         }
         if(this.chat)
         {
            this.chat.appendMessage(_loc6_,_loc3_,param1.msg,param2);
         }
      }
      
      private function processChatRoomMsg(param1:ChatRoomMsg) : void
      {
      }
      
      private function chatEnterFunc(param1:CmdExec) : void
      {
         if(this.chat.focused)
         {
            this.chat.sendMessage();
         }
         else
         {
            this.chat.focusChat();
         }
      }
      
      public function handleEscape() : Boolean
      {
         if(this.chat.focused)
         {
            this.config.keybinder.enableBindsFromGroup(KeyBindGroup.COMBAT);
            this.chat.unfocusChat();
            return true;
         }
         return false;
      }
      
      public function guiBattleChatFocusChanged() : void
      {
         if(!this.config)
         {
            return;
         }
         if(this.chat.focused)
         {
            this.config.keybinder.disableBindsFromGroup(KeyBindGroup.COMBAT);
         }
         else
         {
            this.config.keybinder.enableBindsFromGroup(KeyBindGroup.COMBAT);
         }
      }
      
      public function bringToFront() : void
      {
         var _loc1_:MovieClip = !!this.chat ? this.chat.movieClip : null;
         var _loc2_:GuiSprite = !!_loc1_ ? _loc1_.parent as GuiSprite : null;
         if(Boolean(_loc1_) && Boolean(_loc2_))
         {
            _loc2_.bringChildToFront(_loc1_);
         }
      }
      
      public function set showWhenUnfocused(param1:Boolean) : void
      {
         this._showWhenUnfocused = param1;
         if(this.chat)
         {
            this.chat.showWhenUnfocused = param1;
         }
      }
      
      public function set showChatButton(param1:Boolean) : void
      {
         this._showChatButton = param1;
         if(this.chat)
         {
            this.chat.showChatButton = this._showChatButton;
         }
      }
   }
}
