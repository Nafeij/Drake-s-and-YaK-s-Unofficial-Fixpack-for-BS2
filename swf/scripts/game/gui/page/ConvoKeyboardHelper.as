package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.cmd.KeyBinder;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.saga.SagaCheat;
   import engine.saga.convo.ConvoCursor;
   import engine.saga.convo.def.ConvoOptionDef;
   import flash.ui.Keyboard;
   
   public class ConvoKeyboardHelper
   {
       
      
      private var cmd_convo_next:Cmd;
      
      private var cmd_convo_1:Cmd;
      
      private var cmd_convo_2:Cmd;
      
      private var cmd_convo_3:Cmd;
      
      private var cmd_convo_4:Cmd;
      
      private var cmd_convo_5:Cmd;
      
      private var cmd_convo_6:Cmd;
      
      private var cmd_convo_ff:Cmd;
      
      private var keybinder:KeyBinder;
      
      private var nextCallback:Function;
      
      private var selectCallback:Function;
      
      public var cursor:ConvoCursor;
      
      private var gplayer:int;
      
      public function ConvoKeyboardHelper(param1:KeyBinder, param2:Function, param3:Function, param4:Boolean)
      {
         this.cmd_convo_next = new Cmd("convo_next",this.cmdNextFunc);
         this.cmd_convo_1 = new Cmd("convo_1",this.cmdSelectFunc,0);
         this.cmd_convo_2 = new Cmd("convo_2",this.cmdSelectFunc,1);
         this.cmd_convo_3 = new Cmd("convo_3",this.cmdSelectFunc,2);
         this.cmd_convo_4 = new Cmd("convo_4",this.cmdSelectFunc,3);
         this.cmd_convo_5 = new Cmd("convo_5",this.cmdSelectFunc,4);
         this.cmd_convo_6 = new Cmd("convo_6",this.cmdSelectFunc,5);
         this.cmd_convo_ff = new Cmd("convo_ff",this.cmdFfFunc);
         super();
         if(param2 == null || param3 == null)
         {
            throw new ArgumentError("Fail callback");
         }
         this.keybinder = param1;
         this.nextCallback = param2;
         this.selectCallback = param3;
         this.gplayer = GpBinder.gpbinder.createLayer("ConvoKeyboardHelper");
         if(param4)
         {
            param1.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_convo_ff,KeyBindGroup.CONVO);
         }
         param1.bind(false,false,false,Keyboard.BACK,this.cmd_convo_next,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.ENTER,this.cmd_convo_next,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_ENTER,this.cmd_convo_next,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.SPACE,this.cmd_convo_next,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_1,this.cmd_convo_1,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_1,this.cmd_convo_1,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_2,this.cmd_convo_2,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_2,this.cmd_convo_2,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_3,this.cmd_convo_3,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_3,this.cmd_convo_3,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_4,this.cmd_convo_4,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_4,this.cmd_convo_4,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_5,this.cmd_convo_5,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_5,this.cmd_convo_5,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMBER_6,this.cmd_convo_6,KeyBindGroup.CONVO);
         param1.bind(false,false,false,Keyboard.NUMPAD_6,this.cmd_convo_6,KeyBindGroup.CONVO);
         GpBinder.gpbinder.bindPress(GpControlButton.A,this.cmd_convo_next,KeyBindGroup.CONVO);
         GpDevBinder.instance.bind(null,GpControlButton.A,1,this.doFf);
      }
      
      public function doFf() : Boolean
      {
         this.cmdFfFunc(null);
         return true;
      }
      
      public function cleanup() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         GpDevBinder.instance.unbind(this.doFf);
         GpBinder.gpbinder.unbind(this.cmd_convo_next);
         this.keybinder.unbind(this.cmd_convo_next);
         this.keybinder.unbind(this.cmd_convo_ff);
         this.keybinder.unbind(this.cmd_convo_1);
         this.keybinder.unbind(this.cmd_convo_2);
         this.keybinder.unbind(this.cmd_convo_3);
         this.keybinder.unbind(this.cmd_convo_4);
         this.keybinder.unbind(this.cmd_convo_5);
         this.keybinder.unbind(this.cmd_convo_6);
         this.cmd_convo_next.cleanup();
         this.cmd_convo_ff.cleanup();
         this.cmd_convo_1.cleanup();
         this.cmd_convo_2.cleanup();
         this.cmd_convo_3.cleanup();
         this.cmd_convo_4.cleanup();
         this.cmd_convo_5.cleanup();
         this.cmd_convo_6.cleanup();
         this.cmd_convo_next = null;
         this.cmd_convo_ff = null;
         this.cmd_convo_1 = null;
         this.cmd_convo_2 = null;
         this.cmd_convo_3 = null;
         this.cmd_convo_4 = null;
         this.cmd_convo_5 = null;
         this.cmd_convo_6 = null;
      }
      
      public function cmdSelectFunc(param1:CmdExec) : void
      {
         if(!this.cursor || this.cursor.convo.readyToFinish || this.cursor.convo.finished)
         {
            return;
         }
         var _loc2_:int = param1.cmd.config;
         if(_loc2_ < 0 || _loc2_ >= this.cursor.options.length)
         {
            return;
         }
         var _loc3_:ConvoOptionDef = this.cursor.options[_loc2_];
         this.selectCallback(this.cursor,_loc3_);
      }
      
      public function cmdNextFunc(param1:CmdExec) : void
      {
         if(this.cursor)
         {
            this.nextCallback(this.cursor);
         }
      }
      
      public function cmdFfFunc(param1:CmdExec) : void
      {
         if(this.cursor)
         {
            SagaCheat.devCheat("ff convo");
            this.cursor.ff();
         }
      }
   }
}
