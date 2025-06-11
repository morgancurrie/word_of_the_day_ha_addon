# Word of the Day for H.A.

A "Word of the Day" add-on for Home Assistant. 


[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmorgancurrie%2Fword_of_the_day_ha_addon)

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

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
