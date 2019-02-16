class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # def index
  #   @movies = Movie.all
  # end
  def index	
		@hilite = 'hilite'
		@all_ratings = Movie.ratings
		if params[:ratings]
		  @ratings = params[:ratings]
		end
		if params[:commit] == 'Refresh'
      session[:ratings] = params[:ratings]
    elsif session[:ratings] != params[:ratings]
      redirect = true
      params[:ratings] = session[:ratings]
    end

    if params[:sortby]
      session[:sortby] = params[:sortby]
    elsif session[:sortby]
      redirect = true
      params[:sortby] = session[:sortby]
		end
    
    @ratings, @sortby = session[:ratings], session[:sortby]
    if redirect
      flash.keep
      redirect_to movies_path({:sortby=>@sortby, :ratings=>@ratings})
    elsif
      columns = {'title'=>'title', 'release_date'=>'release_date'}
      if columns.has_key?(@sortby)
        query = Movie.order(columns[@sortby])
      else
        @sortby = nil
        query = Movie
      end

      @movies = @ratings.nil? ? query.all : query.with_ratings(@ratings.map { |r| r[0] })
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
