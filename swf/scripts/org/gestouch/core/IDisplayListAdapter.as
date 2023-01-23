package org.gestouch.core
{
   public interface IDisplayListAdapter extends IGestureTargetAdapter
   {
       
      
      function getHierarchy(param1:Object) : Vector.<Object>;
      
      function reflect() : Class;
   }
}
