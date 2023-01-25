package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphFPSGroup;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import com.junkbyte.console.vos.GraphMemoryGroup;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class Graphing extends ConsoleCore
   {
       
      
      protected var _groups:Array;
      
      protected var _map:Object;
      
      protected var _fpsGroup:GraphGroup;
      
      protected var _memGroup:GraphGroup;
      
      protected var _groupAddedDispatcher:CcCallbackDispatcher;
      
      public function Graphing(param1:Console)
      {
         var m:Console = param1;
         this._groups = [];
         this._map = {};
         this._groupAddedDispatcher = new CcCallbackDispatcher();
         super(m);
         remoter.addEventListener(Event.CONNECT,this.onRemoteConnection);
         remoter.registerCallback("fps",function(param1:ByteArray):void
         {
            fpsMonitor = !fpsMonitor;
         });
         remoter.registerCallback("mem",function(param1:ByteArray):void
         {
            memoryMonitor = !memoryMonitor;
         });
         remoter.registerCallback("removeGraphGroup",this.onRemotingRemoveGraphGroup);
         remoter.registerCallback("menuGraphGroup",this.onRemotingMenuGraphGroup);
      }
      
      public function add(param1:String, param2:Object, param3:String, param4:Number = -1, param5:String = null, param6:Rectangle = null, param7:Boolean = false) : GraphGroup
      {
         var group:GraphGroup;
         var interests:Array;
         var interest:GraphInterest;
         var v:Number;
         var newGroup:Boolean = false;
         var i:GraphInterest = null;
         var n:String = param1;
         var obj:Object = param2;
         var prop:String = param3;
         var col:Number = param4;
         var key:String = param5;
         var rect:Rectangle = param6;
         var inverse:Boolean = param7;
         if(obj == null)
         {
            report("ERROR: Graph [" + n + "] received a null object to graph property [" + prop + "].",10);
            return null;
         }
         group = this._map[n];
         if(!group)
         {
            newGroup = true;
            group = new GraphGroup(n);
         }
         interests = group.interests;
         if(isNaN(col) || col < 0)
         {
            if(interests.length <= 5)
            {
               col = Number(config.style["priority" + (10 - interests.length * 2)]);
            }
            else
            {
               col = Math.random() * 16777215;
            }
         }
         if(key == null)
         {
            key = prop;
         }
         for each(i in interests)
         {
            if(i.key == key)
            {
               report("Graph with key [" + key + "] already exists in [" + n + "]",10);
               return null;
            }
         }
         if(rect)
         {
            group.rect = rect;
         }
         if(inverse)
         {
            group.inverted = inverse;
         }
         interest = new GraphInterest(key,col);
         v = NaN;
         try
         {
            v = interest.setObject(obj,prop);
         }
         catch(e:Error)
         {
            report("Error with graph value for [" + key + "] in [" + n + "]. " + e,10);
            return null;
         }
         if(isNaN(v))
         {
            report("Graph value for key [" + key + "] in [" + n + "] is not a number (NaN).",10);
         }
         else
         {
            group.interests.push(interest);
            if(newGroup)
            {
               this._map[n] = group;
               this.addGroup(group);
            }
         }
         return group;
      }
      
      public function remove(param1:String, param2:Object = null, param3:String = null) : void
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:GraphInterest = null;
         var _loc4_:GraphGroup = this._map[param1];
         if(_loc4_)
         {
            if(param2 == null && param3 == null)
            {
               _loc4_.close();
            }
            else
            {
               _loc5_ = _loc4_.interests;
               _loc6_ = int(_loc5_.length - 1);
               while(_loc6_ >= 0)
               {
                  _loc7_ = _loc5_[_loc6_];
                  if((param2 == null || _loc7_.obj == param2) && (param3 == null || _loc7_.prop == param3))
                  {
                     _loc5_.splice(_loc6_,1);
                  }
                  _loc6_--;
               }
               if(_loc5_.length == 0)
               {
                  _loc4_.close();
               }
            }
         }
      }
      
      public function fixRange(param1:String, param2:Number = NaN, param3:Number = NaN) : void
      {
         var _loc4_:GraphGroup = this._map[param1];
         if(_loc4_)
         {
            _loc4_.fixedMin = param2;
            _loc4_.fixedMax = param3;
         }
      }
      
      public function get onGroupAdded() : CcCallbackDispatcher
      {
         return this._groupAddedDispatcher;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this._fpsGroup != null;
      }
      
      public function set fpsMonitor(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._fpsGroup)
            {
               return;
            }
            this._fpsGroup = new GraphFPSGroup(console);
            this._fpsGroup.onClose.add(this.onFPSGroupClose);
            this.addGroup(this._fpsGroup);
            console.panels.mainPanel.updateMenu();
         }
         else if(this._fpsGroup)
         {
            this._fpsGroup.close();
         }
      }
      
      private function onFPSGroupClose(param1:GraphGroup) : void
      {
         this._fpsGroup = null;
         console.panels.mainPanel.updateMenu();
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this._memGroup != null;
      }
      
      public function set memoryMonitor(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._memGroup)
            {
               return;
            }
            this._memGroup = new GraphMemoryGroup(console);
            this._memGroup.onClose.add(this.onMemGroupClose);
            this.addGroup(this._memGroup);
            console.panels.mainPanel.updateMenu();
         }
         else if(this._memGroup)
         {
            this._memGroup.close();
         }
      }
      
      private function onMemGroupClose(param1:GraphGroup) : void
      {
         this._memGroup = null;
         console.panels.mainPanel.updateMenu();
      }
      
      public function addGroup(param1:GraphGroup) : void
      {
         if(this._groups.indexOf(param1) < 0)
         {
            this._groups.push(param1);
            param1.onClose.add(this.onGroupClose);
            this._groupAddedDispatcher.apply(param1);
            this.syncAddGroup(param1);
         }
      }
      
      protected function onGroupClose(param1:GraphGroup) : void
      {
         var _loc2_:int = this._groups.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this._groups.splice(_loc2_,1);
            this.syncRemoveGroup(_loc2_);
         }
      }
      
      public function update(param1:uint) : void
      {
         var _loc2_:GraphGroup = null;
         for each(_loc2_ in this._groups)
         {
            _loc2_.tick(param1);
         }
      }
      
      protected function onRemoteConnection(param1:Event) : void
      {
         var _loc3_:GraphGroup = null;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeShort(this._groups.length);
         for each(_loc3_ in this._groups)
         {
            _loc3_.writeToBytes(_loc2_);
            this.setupSyncGroupUpdate(_loc3_);
         }
         remoter.send("graphGroups",_loc2_);
      }
      
      protected function onRemotingRemoveGraphGroup(param1:ByteArray) : void
      {
         var _loc2_:uint = uint(param1.readShort());
         var _loc3_:GraphGroup = this._groups[_loc2_];
         if(_loc3_)
         {
            _loc3_.close();
         }
      }
      
      protected function onRemotingMenuGraphGroup(param1:ByteArray) : void
      {
         var _loc2_:uint = uint(param1.readShort());
         var _loc3_:String = param1.readUTF();
         var _loc4_:GraphGroup = this._groups[_loc2_];
         if(_loc4_)
         {
            _loc4_.onMenu.apply(_loc3_);
         }
      }
      
      protected function syncAddGroup(param1:GraphGroup) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.connected)
         {
            _loc2_ = new ByteArray();
            param1.writeToBytes(_loc2_);
            remoter.send("addGraphGroup",_loc2_);
            this.setupSyncGroupUpdate(param1);
         }
      }
      
      protected function syncRemoveGroup(param1:int) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.connected)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeShort(param1);
            remoter.send("removeGraphGroup",_loc2_);
         }
      }
      
      protected function setupSyncGroupUpdate(param1:GraphGroup) : void
      {
         var group:GraphGroup = param1;
         group.onUpdate.add(function(param1:Array):void
         {
            syncGroupUpdate(group,param1);
         });
      }
      
      protected function syncGroupUpdate(param1:GraphGroup, param2:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:ByteArray = null;
         var _loc5_:Number = NaN;
         if(remoter.connected)
         {
            _loc3_ = this._groups.indexOf(param1);
            if(_loc3_ < 0)
            {
               return;
            }
            _loc4_ = new ByteArray();
            _loc4_.writeShort(_loc3_);
            for each(_loc5_ in param2)
            {
               _loc4_.writeDouble(_loc5_);
            }
            remoter.send("updateGraphGroup",_loc4_);
         }
      }
   }
}
