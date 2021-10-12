import { useBackend, useLocalState } from '../backend';
import { Tabs, Box, Dropdown, BlockQuote, Button, LabeledList, Divider, Icon, NoticeBox, NumberInput, Section, Stack, Flex } from '../components';
import { Window } from '../layouts';

export const IdentificationComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    modified_card_data,
    is_authenticated,
    id_computer_process_data,
    selected_main_tab_index,
  } = data;
  return (
    <Window
      width={670}
      height={640}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={selected_main_tab_index === 1}
            onClick={() => act('set_main_tab_index', { index: 1 })}>
            Authentication
          </Tabs.Tab>
          {!!is_authenticated && (
            <>
              <Tabs.Tab
                selected={selected_main_tab_index === 2}
                onClick={() => act('set_main_tab_index', { index: 2 })}>
                Tab two
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected_main_tab_index === 3}
                onClick={() => act('set_main_tab_index', { index: 3 })}>
                Tab three
              </Tabs.Tab>
            </>
          )}
        </Tabs>
        <Box>
          {(selected_main_tab_index === 1) && <TabOneContent />}
          {(selected_main_tab_index === 2) && <TabTwoContent />}
        </Box>
      </Window.Content>
    </Window>
  );
};

const TabOneContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    is_authenticated,
    modified_card_data,
  } = data;

  return (
    <>
      <Section
        title="Authentication"
      >
        <Stack vertical>
          {!authentication_card_data && !is_authenticated && <AuthenticationPanelNotAuthenticated />}
          {authentication_card_data && !is_authenticated && <AuthenticationPanelAuthenticationFailed />}
          {authentication_card_data && is_authenticated && <AuthenticationPanelAuthenticationSuccess />}
        </Stack>
      </Section>
      <Section
        title="Auxillary Inputs"
      >
        <Stack vertical>
          <Stack.Item>
            <strong>Target modification ID: </strong>
            <Button
              icon={modified_card_data ? "id-card" : "eject"}
              onClick={() => act('insert_target_id')}
            >
              {modified_card_data ? ("Eject ID: " + modified_card_data.name) : "Insert ID"}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </>
  );
};

const TabTwoContent = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    is_authenticated,
    modified_card_data,
    id_computer_process_data,
    all_job_selections,
  } = data;

  return (
    <>
      <Section>
        <strong>Target modification ID: </strong>
        <Button
          icon={modified_card_data ? "id-card" : "eject"}
          onClick={() => act('insert_target_id')}
        >
          {modified_card_data ? ("Eject ID: " + modified_card_data.name) : "Insert ID"}
        </Button>
      </Section>
      {modified_card_data && <TabTwoCardModificationPage />}
    </>
  );
};

const TabTwoCardModificationPage = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
    is_authenticated,
    modified_card_data,
    id_computer_process_data: {
      cat_access_fields = [],
    } = {},
    id_computer_process_data,
    all_job_selections,
  } = data;

  return (
    <>
      <Section title="Identification">
        <Stack vertical>
          <Stack.Item>
            Registered:
            <Button
              onClick={() => act('set_identification_field', { field: "registered" })}
            >
              {id_computer_process_data.registered_name}
            </Button>
          </Stack.Item>
          <Stack.Item>
            Assignment:
            <Button
              onClick={() => act('set_identification_field', { field: "assignment" })}
            >
              {id_computer_process_data.assignment}
            </Button>
          </Stack.Item>
          <Stack.Item>
            PIN:
            <Button
              onClick={() => act('set_identification_field', { field: "pin" })}
            >
              ****
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Jobs">
        <Stack>
          <Stack.Item>
            <Dropdown
              selected={!!id_computer_process_data.current_dropdown_selected_job}
              options={all_job_selections}
              width={12}
              onSelected={selected => act('select_dropdown_job', { selection: selected })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon=""
              onClick={() => act('set_access_from_current_selected_dropdown_job', { clear_access: 1, enabled_value_to_set: 1 })}
            >
              Set
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => act('set_access_from_current_selected_dropdown_job', { enabled_value_to_set: 1 })}
            >
              Add access
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="minus"
              onClick={() => act('set_access_from_current_selected_dropdown_job', { enabled_value_to_set: 0 })}
            >
              Subtract access
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Access">
        {cat_access_fields.map(catAccessField => (
          <AccessCategory
            key={catAccessField.category_title}
            {...catAccessField}
          />
        ))}
      </Section>
    </>
  );
};

const AccessCategory = (props, context) => {
  const {
    access_fields: accessFields,
    category_color: categoryColor,
    category_title: categoryTitle,
  } = props;
  const { act } = context; // Mordent -> Gerhazo note: Use act in the ButtonCheckbox component, as usual
  return (
    <Section title={categoryTitle}>
      <Flex
        direction="column"
        wrap="wrap"
        height={5}
        justify="space-evenly"
      >
        {accessFields.map(accessField => (
          <Flex.Item key={accessField.access_permission}>
            <Button.Checkbox
              checked={!!accessField.current_enabled_status}
              onClick={() => act('toggle_access', { selected_access: accessField.access_permission })}
            >
              {accessField.access_description}
            </Button.Checkbox>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const AuthenticationPanelNotAuthenticated = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox info>
          You must insert your ID to continue!
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="eject"
          onClick={() => act('insert_authentication_id')}
        >
          {"Insert ID"}
        </Button>
      </Stack.Item>
      <Stack.Item>
        No ID has been detected. The machine&apos;s functionality is locked down.
      </Stack.Item>
    </>
  );
};

const AuthenticationPanelAuthenticationFailed = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox danger>
          Authentication failed. Access denied.
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="id-card"
          onClick={() => act('insert_authentication_id')}
        >
          {("Eject ID: " + authentication_card_data.name)}
        </Button>
      </Stack.Item>
      <Stack.Item>
        The inserted ID has insufficient clearance to allow for operation of the console.
        The machine&apos;s functionality remains locked down. Please contact higher clearance personnel.
      </Stack.Item>
    </>
  );
};

const AuthenticationPanelAuthenticationSuccess = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    authentication_card_data,
  } = data;

  return (
    <>
      <Stack.Item>
        <NoticeBox success>
          Authentication successful. Access granted.
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <strong>Authentication ID: </strong>
        <Button
          icon="id-card"
          onClick={() => act('insert_authentication_id')}
        >
          {("Eject ID: " + authentication_card_data.name)}
        </Button>
      </Stack.Item>
      <Stack.Item>
        The inserted ID has sufficient clearance to allow for operation of the console.
        The machine&apos;s functionality has been unlocked.
      </Stack.Item>
    </>
  );
};
