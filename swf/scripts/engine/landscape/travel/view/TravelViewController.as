package engine.landscape.travel.view
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.IKeyBinder;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.landscape.view.LandscapeViewController;
   import engine.saga.Saga;
   import engine.saga.SagaCheat;
   import flash.ui.Keyboard;
   
   public class TravelViewController
   {
      
      private static var BINDGROUP:String = KeyBindGroup.TRAVEL;
       
      
      public var view:TravelView;
      
      private var cmd_pause:Cmd;
      
      private var cmd_left:Cmd;
      
      private var cmd_right:Cmd;
      
      private var cmd_reverse:Cmd;
      
      private var cmd_jump_left:Cmd;
      
      private var cmd_jump_right:Cmd;
      
      private var cmd_show_travel:Cmd;
      
      private var cmd_halt:Cmd;
      
      private var cmd_show_caravan:Cmd;
      
      private var keybinder:IKeyBinder;
      
      private var landscapeViewController:LandscapeViewController;
      
      private const speed_incr:Number = 0.5;
      
      private var hasHalted:Boolean;
      
      public function TravelViewController(param1:TravelView, param2:LandscapeViewController)
      {
         this.cmd_pause = new Cmd("cmd_pause",this.cmdfunc_pause);
         this.cmd_left = new Cmd("cmd_left",this.cmdfunc_left);
         this.cmd_right = new Cmd("cmd_right",this.cmdfunc_right);
         this.cmd_reverse = new Cmd("cmd_reverse",this.cmdfunc_reverse);
         this.cmd_jump_left = new Cmd("cmd_jump_left",this.cmdfunc_jump_left);
         this.cmd_jump_right = new Cmd("cmd_jump_right",this.cmdfunc_jump_right);
         this.cmd_show_travel = new Cmd("cmd_show_travel",this.cmdfunc_show_travel);
         this.cmd_halt = new Cmd("cmd_halt",this.cmdfunc_halt);
         this.cmd_show_caravan = new Cmd("cmd_show_caravan",this.cmdfunc_show_caravan);
         super();
         this.view = param1;
         this.landscapeViewController = param2;
         this.keybinder = param1.travel.landscape.context.keybinder;
         var _loc3_:Boolean = param1.travel.landscape.scene._context.developer;
         if(_loc3_)
         {
            this.keybinder.bind(true,false,true,Keyboard.SPACE,this.cmd_pause,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.LEFT,this.cmd_left,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.RIGHT,this.cmd_right,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.SLASH,this.cmd_reverse,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_jump_right,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.LEFTBRACKET,this.cmd_jump_left,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.T,this.cmd_show_travel,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.H,this.cmd_halt,BINDGROUP);
            this.keybinder.bind(true,false,true,Keyboard.I,this.cmd_show_caravan,BINDGROUP);
         }
         GpDevBinder.instance.bind(null,GpControlButton.A,1,this.doFf);
      }
      
      public function cleanup() : void
      {
         GpDevBinder.instance.unbind(this.doFf);
         this.keybinder.unbind(this.cmd_pause);
         this.keybinder.unbind(this.cmd_left);
         this.keybinder.unbind(this.cmd_right);
         this.keybinder.unbind(this.cmd_reverse);
         this.keybinder.unbind(this.cmd_jump_right);
         this.keybinder.unbind(this.cmd_jump_left);
         this.keybinder.unbind(this.cmd_show_travel);
         this.keybinder.unbind(this.cmd_halt);
         this.keybinder.unbind(this.cmd_show_caravan);
         this.cmd_pause.cleanup();
         this.cmd_left.cleanup();
         this.cmd_right.cleanup();
         this.cmd_reverse.cleanup();
         this.cmd_jump_right.cleanup();
         this.cmd_jump_left.cleanup();
         this.cmd_show_travel.cleanup();
         this.cmd_halt.cleanup();
         this.cmd_show_caravan.cleanup();
         this.cmd_pause = null;
         this.cmd_left = null;
         this.cmd_right = null;
         this.cmd_reverse = null;
         this.cmd_jump_right = null;
         this.cmd_jump_left = null;
         this.cmd_show_travel = null;
         this.cmd_halt = null;
         this.cmd_show_caravan = null;
         this.keybinder = null;
         this.view = null;
      }
      
      private function get ready() : Boolean
      {
         return Boolean(this.view.travel) && this.view.landscapeView.landscape.scene.ready;
      }
      
      private function cmdfunc_pause(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         this.view.travel.moving = !this.view.travel.moving;
      }
      
      private function cmdfunc_left(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         if(this.view.travel.forward)
         {
            this.view.travel.speed -= this.speed_incr;
         }
         else
         {
            this.view.travel.speed += this.speed_incr;
         }
      }
      
      private function cmdfunc_right(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         if(this.view.travel.forward)
         {
            this.view.travel.speed += this.speed_incr;
         }
         else
         {
            this.view.travel.speed -= this.speed_incr;
         }
      }
      
      private function cmdfunc_jump_left(param1:CmdExec) : void
      {
         if(!this.view || !this.view.travel || !this.view.travel.landscape || !this.view.travel.landscape.scene)
         {
            return;
         }
         if(!this.ready)
         {
            return;
         }
         this.view.travel.jumpBack();
      }
      
      public function doFf() : Boolean
      {
         return this._performDoFf();
      }
      
      private function cmdfunc_jump_right(param1:CmdExec) : void
      {
         this.doFf();
      }
      
      private function _performDoFf() : Boolean
      {
         SagaCheat.devCheat("ff travel");
         if(!this.view || !this.view.travel || !this.view.travel.landscape || !this.view.travel.landscape.scene)
         {
            return false;
         }
         this.view.travel.landscape.scene.forceReady();
         if(!this.ready)
         {
            return true;
         }
         if(!this.view.travel.jumpForward())
         {
            return this.landscapeViewController.doFf(true);
         }
         return false;
      }
      
      private function cmdfunc_show_travel(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         var _loc2_:Boolean = this.view.overlay.showSpline;
         this.view.overlay.showSpline = !_loc2_;
         this.view.overlay.showLocations = !_loc2_;
      }
      
      private function cmdfunc_show_caravan(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         var _loc2_:Saga = this.view.travel.landscape.scene._context.saga as Saga;
         if(!_loc2_)
         {
            return;
         }
         _loc2_.showCaravan = !_loc2_.showCaravan;
      }
      
      private function cmdfunc_halt(param1:CmdExec) : void
      {
         if(!this.ready)
         {
            return;
         }
         var _loc2_:Saga = this.view.travel.landscape.scene._context.saga as Saga;
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_.halting)
         {
            if(this.hasHalted)
            {
               _loc2_.cancelHalting("cmdfunc_halt");
               this.hasHalted = false;
            }
         }
         else if(!this.hasHalted)
         {
            _loc2_.setHalting(null,"cmdfunc_halt");
            this.hasHalted = true;
         }
      }
      
      private function cmdfunc_reverse(param1:CmdExec) : void
      {
         this.view.travel.forward = !this.view.travel.forward;
      }
      
      public function clear() : void
      {
      }
      
      final public function mouseDownHandler(param1:Number, param2:Number) : void
      {
      }
      
      final public function mouseUpHandler(param1:Number, param2:Number) : void
      {
      }
      
      final public function mouseMoveHandler(param1:Number, param2:Number) : void
      {
      }
   }
}
