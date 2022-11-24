#ifndef HELPER_HPP
#define HELPER_HPP

#include "AOM_edna/edna_install_linux_debug_pc/include/com/easydrive/bcore/adas/AdasisV3.hpp"

class Helper : public na::sdk::com::easydrive::bcore::adas::v3::AdasisV3
{
       /**
    * @brief Adds a listener to this client.
    * 
    * The call fails if the listener is already assigned to this client.
    * 
    * @param listenerPtr new listener to add
    * @return \c true on succes, or \c false on error
    */
   virtual bool addListener( IListener *listenerPtr) {};
   
   /**
    * @brief Removes a listener from this client.
    * 
    * The call fails if the listener has not been added before.
    * 
    * @param listenerPtr new listener to remove
    * @return \c true on succes, or \c false on error
    */
   virtual bool removeListener( IListener *listenerPtr) {};

      // methods
   virtual void PostExternalPosition( uint64_t timeStamp_, uint32_t radius_, const BasePosition &position_, double heading_, RequestDataType dataType_, void *ticket = 0) {};
   
   virtual void LaneGroupNotification( uint32_t pathId_, uint32_t offsetOnPath_, uint64_t linkId_, uint32_t offsetOnLink_, void *ticket = 0) {};
   
   
   // broadcasts
   virtual void registerAV3MsgNotification() {};
   virtual void unregisterAV3MsgNotification() {};
public:
    Helper(/* args */);
    ~Helper();
};

#endif // HELPER_HPP