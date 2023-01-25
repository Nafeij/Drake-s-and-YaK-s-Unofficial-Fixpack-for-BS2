package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.console_internal;
   import com.junkbyte.console.vos.GraphGroup;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   
   public class PanelsManager
   {
       
      
      protected var console:Console;
      
      protected var _mainPanel:MainPanel;
      
      private var _chsPanel:ChannelsPanel;
      
      private var _graphsMap:Dictionary;
      
      private var _tooltipField:TextField;
      
      private var _canDraw:Boolean;
      
      public function PanelsManager(param1:Console)
      {
         this._graphsMap = new Dictionary();
         super();
         this.console = param1;
         this._mainPanel = this.createMainPanel();
         this._tooltipField = this.mainPanel.makeTF("tooltip",true);
         this._tooltipField.mouseEnabled = false;
         this._tooltipField.autoSize = TextFieldAutoSize.CENTER;
         this._tooltipField.multiline = true;
         this.addPanel(this._mainPanel);
         this.console.graphing.onGroupAdded.add(this.onGraphingGroupAdded);
      }
      
      protected function createMainPanel() : MainPanel
      {
         return new MainPanel(this.console);
      }
      
      public function addPanel(param1:ConsolePanel) : void
      {
         if(this.console.contains(this._tooltipField))
         {
            this.console.addChildAt(param1,this.console.getChildIndex(this._tooltipField));
         }
         else
         {
            this.console.addChild(param1);
         }
         param1.addEventListener(ConsolePanel.DRAGGING_STARTED,this.onPanelStartDragScale,false,0,true);
         param1.addEventListener(ConsolePanel.SCALING_STARTED,this.onPanelStartDragScale,false,0,true);
      }
      
      public function removePanel(param1:String) : void
      {
         var _loc2_:ConsolePanel = this.console.getChildByName(param1) as ConsolePanel;
         if(_loc2_)
         {
            _loc2_.close();
         }
      }
      
      public function getPanel(param1:String) : ConsolePanel
      {
         return this.console.getChildByName(param1) as ConsolePanel;
      }
      
      public function get mainPanel() : MainPanel
      {
         return this._mainPanel;
      }
      
      public function panelExists(param1:String) : Boolean
      {
         return !!(this.console.getChildByName(param1) as ConsolePanel) ? true : false;
      }
      
      public function setPanelArea(param1:String, param2:Rectangle) : void
      {
         var _loc3_:ConsolePanel = this.getPanel(param1);
         if(_loc3_)
         {
            _loc3_.x = param2.x;
            _loc3_.y = param2.y;
            if(param2.width)
            {
               _loc3_.width = param2.width;
            }
            if(param2.height)
            {
               _loc3_.height = param2.height;
            }
         }
      }
      
      public function updateMenu() : void
      {
         this._mainPanel.updateMenu();
         var _loc1_:ChannelsPanel = this.getPanel(ChannelsPanel.NAME) as ChannelsPanel;
         if(_loc1_)
         {
            _loc1_.update();
         }
      }
      
      console_internal function update(param1:Boolean, param2:Boolean) : void
      {
         this._canDraw = !param1;
         this._mainPanel.update(!param1 && param2);
         if(!param1)
         {
            if(param2 && this._chsPanel != null)
            {
               this._chsPanel.update();
            }
         }
      }
      
      private function onGraphingGroupAdded(param1:GraphGroup) : void
      {
         param1.onClose.add(this.onGraphGroupClose);
         var _loc2_:GraphingPanel = new GraphingPanel(this.console,param1);
         this._graphsMap[param1] = _loc2_;
         this.addPanel(_loc2_);
      }
      
      private function onGraphGroupClose(param1:GraphGroup) : void
      {
         var _loc2_:GraphingPanel = this.getGraphByGroup(param1);
         if(_loc2_)
         {
            delete this._graphsMap[param1];
            _loc2_.close();
         }
      }
      
      public function getGraphByGroup(param1:GraphGroup) : GraphingPanel
      {
         return this._graphsMap[param1];
      }
      
      public function get displayRoller() : Boolean
      {
         return !!(this.getPanel(RollerPanel.NAME) as RollerPanel) ? true : false;
      }
      
      public function set displayRoller(param1:Boolean) : void
      {
         var _loc2_:RollerPanel = null;
         if(this.displayRoller != param1)
         {
            if(param1)
            {
               if(this.console.config.displayRollerEnabled)
               {
                  _loc2_ = new RollerPanel(this.console);
                  _loc2_.x = this._mainPanel.x + this._mainPanel.width - 180;
                  _loc2_.y = this._mainPanel.y + 55;
                  this.addPanel(_loc2_);
               }
               else
               {
                  this.console.report("Display roller is disabled in config.",9);
               }
            }
            else
            {
               this.removePanel(RollerPanel.NAME);
            }
            this._mainPanel.updateMenu();
         }
      }
      
      public function get channelsPanel() : Boolean
      {
         return this._chsPanel != null;
      }
      
      public function set channelsPanel(param1:Boolean) : void
      {
         if(this.channelsPanel != param1)
         {
            this.console.logs.cleanChannels();
            if(param1)
            {
               this._chsPanel = new ChannelsPanel(this.console);
               this._chsPanel.x = this._mainPanel.x + this._mainPanel.width - 332;
               this._chsPanel.y = this._mainPanel.y - 2;
               this.addPanel(this._chsPanel);
               this._chsPanel.update();
               this.updateMenu();
            }
            else
            {
               this.removePanel(ChannelsPanel.NAME);
               this._chsPanel = null;
            }
            this.updateMenu();
         }
      }
      
      public function tooltip(param1:String = null, param2:ConsolePanel = null) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Rectangle = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(param1)
         {
            _loc3_ = param1.split("::");
            param1 = String(_loc3_[0]);
            if(_loc3_.length > 1)
            {
               param1 += "<br/><low>" + _loc3_[1] + "</low>";
            }
            this.console.addChild(this._tooltipField);
            this._tooltipField.wordWrap = false;
            this._tooltipField.htmlText = "<tt>" + param1 + "</tt>";
            if(this._tooltipField.width > 120)
            {
               this._tooltipField.width = 120;
               this._tooltipField.wordWrap = true;
            }
            this._tooltipField.x = this.console.mouseX - this._tooltipField.width / 2;
            this._tooltipField.y = this.console.mouseY + 20;
            if(param2)
            {
               _loc4_ = this._tooltipField.getBounds(this.console);
               _loc5_ = new Rectangle(param2.x,param2.y,param2.width,param2.height);
               _loc6_ = _loc4_.bottom - _loc5_.bottom;
               if(_loc6_ > 0)
               {
                  if(this._tooltipField.y - _loc6_ > this.console.mouseY + 15)
                  {
                     this._tooltipField.y -= _loc6_;
                  }
                  else if(_loc5_.y < this.console.mouseY - 24 && _loc4_.y > _loc5_.bottom)
                  {
                     this._tooltipField.y = this.console.mouseY - this._tooltipField.height - 15;
                  }
               }
               _loc7_ = _loc4_.left - _loc5_.left;
               _loc8_ = _loc4_.right - _loc5_.right;
               if(_loc7_ < 0)
               {
                  this._tooltipField.x -= _loc7_;
               }
               else if(_loc8_ > 0)
               {
                  this._tooltipField.x -= _loc8_;
               }
            }
         }
         else if(this.console.contains(this._tooltipField))
         {
            this.console.removeChild(this._tooltipField);
         }
      }
      
      private function onPanelStartDragScale(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:ConsolePanel = null;
         var _loc2_:ConsolePanel = param1.currentTarget as ConsolePanel;
         if(this.console.config.style.panelSnapping)
         {
            _loc3_ = [0];
            _loc4_ = [0];
            if(this.console.stage)
            {
               _loc3_.push(this.console.stage.stageWidth);
               _loc4_.push(this.console.stage.stageHeight);
            }
            _loc5_ = this.console.numChildren;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc7_ = this.console.getChildAt(_loc6_) as ConsolePanel;
               if(Boolean(_loc7_) && _loc7_.visible)
               {
                  _loc3_.push(_loc7_.x,_loc7_.x + _loc7_.width);
                  _loc4_.push(_loc7_.y,_loc7_.y + _loc7_.height);
               }
               _loc6_++;
            }
            _loc2_.registerSnaps(_loc3_,_loc4_);
         }
      }
   }
}
