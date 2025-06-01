# Word of the Day for H.A.

A "Word of the Day" add-on for Home Assistant. 

This will add a new sensor entity called "Word of the Day" which pulls a line from words.csv based on the current day of the year (eg. January 3 == row 3). Each line in the CSV contains 3 parts: a word, a definition, and an example sentence. These are available as individual attributes on the entity.

For displaying on a dashboard, I recommened using a Mushroom Template Card, with something like the following pasted into the Code Editor:

    type: custom:mushroom-template-card
    secondary: >-
    {{state_attr('sensor.word_of_the_day_addon','word_of_the_day')}}:
    {{state_attr('sensor.word_of_the_day_addon','definition')}}


    Example: {{state_attr('sensor.word_of_the_day_addon','example_sentence')}}
    entity: sensor.word_of_the_day_addon
    multiline_secondary: true
    layout: horizontal
    primary: 📚 Word of the Day
    fill_container: false
    icon: ""
    icon_color: ""
    card_mod:
    style: |
        ha-card {
        padding: 0 8px 8px 8px;
        --card-primary-font-size: 24px;
        --card-primary-line-height: 54px;
        --card-primary-font-weight: 400;
        --card-secondary-font-size: 14px;
        --card-secondary-line-height: 16.8px;
        }
    tap_action:
    action: none

This will render something similar to this:

![Screenshot of styled example](/screenshot.png?raw=true "Screenshot")
