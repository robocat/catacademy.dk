DEV = location.hostname == 'catacademy.dev'

class Event
  class @Header
    @render: (event) ->
      progress = (event.seats.taken / event.seats.maximum) * 100
      console.log event
      reward = event.rewards[0]
      """
        <div class=event-header
             id="#{event.slug}"
             style="background-color: #{event.color}">
          <span class=tag
                style="color: #{event.color}">
            #{event.tags.join(' + ')}
          </span>

          <hr/>

          <div class=dates>#{event.dates}</div>
          <h1>#{event.name}</h1>

          <div class=progress-bar>
            <div class=seats-available>
              <div class=value>
                #{event.seats.available}/#{event.seats.maximum}
              </div>
              Seats available
            </div>
            <div class=seat-goal>
              <div class=value>
                #{event.seats.minimum}
              </div>
              Seat goal
            </div>
            <div class=bar>
              <div class=progress style="width: #{progress}%"></div>
            </div>

            <p><a class=buy href='#'>Buy #{reward.name}</a><br/>
            #{reward.price.pretty}</p>
          </div>

        </div>
      """


  class @Card
    @render: (event) ->
      color = if event.is_over then 'grey' else event.color
      """
        <div class=event-card style="background-color: #{color}">
          <span class=tag
                style="color: #{color}">
            #{event.tags.join(' + ')}
          </span>
          <div class=dates>#{event.dates}</div>
          <h1 class=name>#{event.name}</h1>
          #{@render_link event}
        </div>
      """

    @render_link: (event) ->
      if event.is_over
        """<span class=action>Event is over</span>"""
      else
        """<a class=action href="##{event.slug}">Learn more</a>"""



class API
  @url: 'https://catacademy-test.herokuapp.com'

  @get_root: (callback) ->
    console.log @url
    $.getJSON(@url).done callback

  @post_pledge: (reward_id, token, callback) ->
    url = "#{@url}/rewards/#{reward_id}/pledges"
    $.ajax(url, {
      type: 'POST',
      contentType: 'application/json',
      data: JSON.stringify(token),
    }).done callback


class Checkout
  @create: (key, callback) ->
    StripeCheckout.configure
      key: key
      image: if DEV then null else 'images/checkout-logo.png'
      token: callback


render = () ->
  API.get_root ({events, stripe}) ->
    $('.event-card-list').empty()
    events.map (event) ->
      reward = event.rewards[0]
      $('.event-card-list').append(Event.Card.render(event))
      if not event.is_over
        id = '#' + event.slug
        $(id)[0].innerHTML = Event.Header.render(event)
        $(id).hide().fadeIn('slow')
        checkout = Checkout.create stripe.publishable_key, (token) ->
          API.post_pledge reward.id, token, () ->
            alert """Thanks joining the event. Confirmation email will be sent \
                     shortly to #{token.email}"""
            render()
        console.log 'map'
        $(id + ' .buy').on 'click', (e) ->
          console.log('buy')
          checkout.open
            name: 'Cat Academy'
            description: "Pledge for course: #{event.name}"
            amount: reward.price.amount * 100
            currency: 'dkk'
            panelLabel: 'Pledge {{amount}}'
            allowRememberMe: false
          e.preventDefault()
render()


$('a[href^="#"]').on 'click', (event) ->
  target = $($(this).attr('href'))
  if target.length
    event.preventDefault()
    $('html, body').animate {scrollTop: target.offset().top}, 500, ->
      target.focus()

$('.newsletter form').on 'submit', (e) ->
  e.preventDefault()
  url = 'https://robocat-newsletters.herokuapp.com/signup'
  post_data = {email: $('input.email').val(), list: 'cat-academy'}
  $.post url, post_data, ({status, message}, _status, _xhr) ->
    $('input.email').attr('disabled', 'disabled')
    $('input.email').val('Thank you.')
    $('input.subscribe').attr('disabled', 'disabled').css('opacity', 0)
    $('.tweet').fadeIn('slow')
