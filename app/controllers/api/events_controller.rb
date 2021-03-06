class Api::EventsController < ApplicationController

    def index
        @events = Event.all
        render :index
    end

    def show
        @event = Event.find_by(id: params[:id])
        render :show
    end



    def create
      all_params = event_params
      city = City.find_by(name: all_params[:city])

      if city
        all_params[:city_id] = city.id
      end
      all_params.delete(:city)

      @event = Event.new(all_params)

      if @event.save
        render :show
      else
        render json: @event.errors.full_messages, status: 422
      end
    end

    def update
      @event = current_user.hosted_events.find(params[:id])

      all_params = event_params
      all_params[:city_id] = City.find_by(name: all_params[:city]).id
      all_params.delete(:city)

      if @event.update(all_params)
        render :show
      else
        render json: @event.errors.full_messages, status: 422
      end
    end

    def destroy
      @event = current_user.hosted_events.find(params[:id])
      @event.destroy
      render :show
    end


    def event_params
        params.require(:event).permit(:name, :description, :date, :time,
          :address, :city, :host_id)
    end

    def dashboard_events
      @rsvps = current_user.rsvps
      @joined_events = current_user.joined_events
      @hosted_events = current_user.hosted_events

      render :index

    end



end
